import Foundation

/// Primary entry point for the Critic SDK.
public final class Critic: @unchecked Sendable {

    /// Shared singleton instance.
    public static let shared = Critic()

    /// The API client, available after initialization.
    public private(set) var api: CriticAPI?

    /// The app install ID, set after a successful ping.
    public private(set) var appInstallId: String?

    /// The API token used for this session.
    public private(set) var apiToken: String?

    /// The base URL for the Critic API.
    public private(set) var baseURL: URL

    private let lock = NSLock()

    private init() {
        self.baseURL = URL(string: "https://critic.inventiv.io")!
    }

    /// Initialize the SDK with an organization API token.
    /// Performs a ping to register the device and app install.
    #if canImport(UIKit)
    @MainActor
    public func initialize(
        apiToken: String,
        baseURL: URL? = nil
    ) async throws {
        let resolvedBaseURL = baseURL ?? self.baseURL

        lock.lock()
        self.apiToken = apiToken
        self.baseURL = resolvedBaseURL
        self.api = CriticAPI(baseURL: resolvedBaseURL, apiToken: apiToken)
        lock.unlock()

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

        guard let api else { throw CriticError.notInitialized }
        let appInstall = try await api.ping(pingRequest)

        lock.lock()
        self.appInstallId = appInstall.id
        lock.unlock()
    }
    #endif

    /// Submit a bug report with optional file attachments.
    public func submitReport(
        _ report: BugReportInput,
        attachments: [(filename: String, mimeType: String, data: Data)]? = nil
    ) async throws -> BugReport {
        guard let api else { throw CriticError.notInitialized }
        guard let appInstallId else { throw CriticError.notInitialized }

        #if canImport(UIKit)
        let deviceInfo = DeviceInfo()
        let deviceStatus = await MainActor.run { deviceInfo.collectDeviceStatus() }
        #else
        let deviceStatus: DeviceStatus? = nil
        #endif

        return try await api.createBugReport(
            report: report,
            appInstallId: appInstallId,
            attachments: attachments,
            deviceStatus: deviceStatus
        )
    }
}
