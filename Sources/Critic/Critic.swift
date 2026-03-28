import Foundation

/// Primary entry point for the Critic SDK.
///
/// Use the ``shared`` singleton to initialize the SDK and submit bug reports.
///
/// ## Getting Started
///
/// Initialize the SDK early in your app lifecycle:
///
/// ```swift
/// try await Critic.shared.initialize(apiToken: "YOUR_API_TOKEN")
/// ```
///
/// Then submit reports:
///
/// ```swift
/// let input = BugReportInput(description: "Something broke")
/// let report = try await Critic.shared.submitReport(input)
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``initialize(apiToken:baseURL:)``
///
/// ### Submitting Reports
/// - ``submitReport(_:attachments:)``
///
/// ### Properties
/// - ``shared``
/// - ``api``
/// - ``appInstallId``
/// - ``apiToken``
/// - ``baseURL``
public final class Critic: @unchecked Sendable {

    /// The shared singleton instance of the Critic SDK.
    public static let shared = Critic()

    /// The API client, available after ``initialize(apiToken:baseURL:)`` is called.
    public private(set) var api: CriticAPI?

    /// The app install ID assigned by the server after a successful ping.
    public private(set) var appInstallId: String?

    /// The API token used for this session.
    public private(set) var apiToken: String?

    /// The base URL for the Critic API. Defaults to `https://critic.inventiv.io`.
    public private(set) var baseURL: URL

    private let lock = NSLock()

    private init() {
        self.baseURL = URL(string: "https://critic.inventiv.io")!
    }

    /// Thread-safe read of mutable properties used by public methods.
    private func lockedState() -> (api: CriticAPI?, appInstallId: String?) {
        lock.withLock { (self.api, self.appInstallId) }
    }

    /// Initialize the SDK with an organization API token.
    ///
    /// Performs a ping to register the device and app install with the Critic server.
    /// Must be called before ``submitReport(_:attachments:)``.
    ///
    /// - Parameters:
    ///   - apiToken: Your organization's API token from the Critic web portal.
    ///   - baseURL: Optional custom base URL for self-hosted instances. Defaults to `https://critic.inventiv.io`.
    /// - Throws: ``CriticError`` if the ping request fails.
    #if canImport(UIKit)
    @MainActor
    public func initialize(
        apiToken: String,
        baseURL: URL? = nil
    ) async throws {
        let resolvedBaseURL = baseURL ?? self.baseURL

        lock.withLock {
            self.apiToken = apiToken
            self.baseURL = resolvedBaseURL
            self.api = CriticAPI(baseURL: resolvedBaseURL, apiToken: apiToken)
        }

        let deviceInfo = DeviceInfo()
        let deviceInfoData = deviceInfo.collectDeviceInfoData()
        let deviceStatus = deviceInfo.collectDeviceStatus()

        let bundle = Bundle.main
        let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Unknown"
        let bundleId = bundle.bundleIdentifier ?? "unknown"
        let versionName = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"

        let appInfo = AppInfo(
            name: appName,
            package: bundleId,
            platform: "iOS",
            version: AppVersionInfo(code: buildNumber, name: versionName)
        )

        let pingRequest = PingRequest(
            apiToken: apiToken,
            app: appInfo,
            device: deviceInfoData,
            deviceStatus: deviceStatus
        )

        guard let api = lock.withLock({ self.api }) else { throw CriticError.notInitialized }
        let appInstall = try await api.ping(pingRequest)

        lock.withLock {
            self.appInstallId = appInstall.id
        }
    }
    #endif

    /// Submit a bug report with optional file attachments.
    ///
    /// The SDK must be initialized via ``initialize(apiToken:baseURL:)`` before calling this method.
    /// Device status (battery, memory, disk) is automatically collected and included with the report.
    ///
    /// - Parameters:
    ///   - report: The bug report input containing description, metadata, and other fields.
    ///   - attachments: Optional array of file attachments (filename, MIME type, and data).
    /// - Returns: The created ``BugReport`` as returned by the server.
    /// - Throws: ``CriticError/notInitialized`` if the SDK has not been initialized,
    ///   or another ``CriticError`` if the request fails.
    public func submitReport(
        _ report: BugReportInput,
        attachments: [(filename: String, mimeType: String, data: Data)]? = nil
    ) async throws -> BugReport {
        let (api, appInstallId) = lockedState()

        guard let api else { throw CriticError.notInitialized }
        guard let appInstallId else { throw CriticError.notInitialized }

        #if canImport(UIKit)
        let deviceInfo = DeviceInfo()
        let deviceStatus = await MainActor.run { deviceInfo.collectDeviceStatus() }
        #else
        let deviceStatus: DeviceStatus? = nil
        #endif

        var allAttachments = attachments ?? []

        if #available(iOS 15.0, macOS 12.0, *) {
            if let logAttachment = LogCapture.captureRecentLogs() {
                allAttachments.append(logAttachment)
            }
        }

        return try await api.createBugReport(
            report: report,
            appInstallId: appInstallId,
            attachments: allAttachments.isEmpty ? nil : allAttachments,
            deviceStatus: deviceStatus
        )
    }
}
