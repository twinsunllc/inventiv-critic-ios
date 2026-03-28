import Foundation

/// Handles communication with the Critic v3 REST API.
///
/// `CriticAPI` is an actor that provides type-safe access to all Critic API endpoints.
/// It is typically accessed through ``Critic/api`` after SDK initialization, but can also
/// be created directly for custom configurations.
///
/// ## Topics
///
/// ### Registration
/// - ``ping(_:)``
///
/// ### Bug Reports
/// - ``createBugReport(report:appInstallId:attachments:deviceStatus:)``
/// - ``listBugReports(appApiToken:archived:deviceId:since:)``
/// - ``getBugReport(id:appApiToken:)``
///
/// ### Devices
/// - ``listDevices(appApiToken:)``
public actor CriticAPI {

    /// The base URL for API requests (e.g. `https://critic.inventiv.io`).
    public let baseURL: URL

    /// The organization API token used for authenticated POST endpoints.
    public let apiToken: String

    private let session: URLSession
    private let decoder: JSONDecoder

    /// Creates a new API client.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL of the Critic API server.
    ///   - apiToken: The organization API token for authentication.
    ///   - session: The URL session to use for requests. Defaults to `.shared`.
    public init(baseURL: URL, apiToken: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiToken = apiToken
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Ping

    /// Register an app install with the Critic API.
    ///
    /// Sends device and app information to the server and receives an app install ID
    /// that is used for subsequent API calls.
    ///
    /// - Parameter request: The ping request containing app, device, and status information.
    /// - Returns: The ``AppInstall`` with the server-assigned install ID.
    /// - Throws: ``CriticError`` if the request fails.
    public func ping(_ request: PingRequest) async throws -> AppInstall {
        let url = Endpoints.ping(baseURL: baseURL)
        let body = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body

        let response: PingResponse = try await perform(urlRequest)
        return response.appInstall
    }

    // MARK: - Bug Reports

    /// Create a bug report with optional file attachments.
    ///
    /// Submits a bug report as multipart form data, including optional file attachments
    /// and device status information.
    ///
    /// - Parameters:
    ///   - report: The bug report input data.
    ///   - appInstallId: The app install ID from a prior ``ping(_:)`` call.
    ///   - attachments: Optional file attachments to include with the report.
    ///   - deviceStatus: Optional device status snapshot at the time of the report.
    /// - Returns: The created ``BugReport`` as returned by the server.
    /// - Throws: ``CriticError`` if the request fails.
    public func createBugReport(
        report: BugReportInput,
        appInstallId: String,
        attachments: [(filename: String, mimeType: String, data: Data)]? = nil,
        deviceStatus: DeviceStatus? = nil
    ) async throws -> BugReport {
        let url = Endpoints.bugReports(baseURL: baseURL)

        var formData = MultipartFormData()
        formData.addField(name: "api_token", value: apiToken)
        formData.addField(name: "app_install[id]", value: appInstallId)
        formData.addField(name: "bug_report[description]", value: report.description)

        if let metadata = report.metadata {
            if let jsonData = try? JSONSerialization.data(withJSONObject: metadata),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                formData.addField(name: "bug_report[metadata]", value: jsonString)
            }
        }
        if let steps = report.stepsToReproduce {
            formData.addField(name: "bug_report[steps_to_reproduce]", value: steps)
        }
        if let user = report.userIdentifier {
            formData.addField(name: "bug_report[user_identifier]", value: user)
        }

        if let attachments {
            for attachment in attachments {
                formData.addFile(
                    name: "bug_report[attachments][]",
                    filename: attachment.filename,
                    mimeType: attachment.mimeType,
                    data: attachment.data
                )
            }
        }

        if let status = deviceStatus {
            addDeviceStatusFields(to: &formData, status: status)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = formData.build()

        return try await perform(urlRequest)
    }

    /// List bug reports for an app.
    ///
    /// - Parameters:
    ///   - appApiToken: The app-specific API token.
    ///   - archived: Filter by archived status. Pass `nil` for all reports.
    ///   - deviceId: Filter by device ID. Pass `nil` for all devices.
    ///   - since: Filter reports created after this ISO 8601 date string.
    /// - Returns: A ``PaginatedResponse`` containing ``BugReport`` items.
    /// - Throws: ``CriticError`` if the request fails.
    public func listBugReports(
        appApiToken: String,
        archived: Bool? = nil,
        deviceId: String? = nil,
        since: String? = nil
    ) async throws -> PaginatedResponse<BugReport> {
        var url = Endpoints.bugReports(baseURL: baseURL)
        var queryItems = [URLQueryItem(name: "app_api_token", value: appApiToken)]

        if let archived {
            queryItems.append(URLQueryItem(name: "archived", value: String(archived)))
        }
        if let deviceId {
            queryItems.append(URLQueryItem(name: "device_id", value: deviceId))
        }
        if let since {
            queryItems.append(URLQueryItem(name: "since", value: since))
        }

        url = url.appending(queryItems: queryItems)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        return try await perform(urlRequest)
    }

    /// Get a single bug report by ID.
    ///
    /// - Parameters:
    ///   - id: The UUID string of the bug report.
    ///   - appApiToken: The app-specific API token.
    /// - Returns: The requested ``BugReport``.
    /// - Throws: ``CriticError/notFound`` if the report does not exist, or another ``CriticError`` on failure.
    public func getBugReport(id: String, appApiToken: String) async throws -> BugReport {
        var url = Endpoints.bugReport(baseURL: baseURL, id: id)
        url = url.appending(queryItems: [URLQueryItem(name: "app_api_token", value: appApiToken)])

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        return try await perform(urlRequest)
    }

    // MARK: - Devices

    /// List devices for an app.
    ///
    /// - Parameter appApiToken: The app-specific API token.
    /// - Returns: A ``PaginatedResponse`` containing ``Device`` items.
    /// - Throws: ``CriticError`` if the request fails.
    public func listDevices(appApiToken: String) async throws -> PaginatedResponse<Device> {
        var url = Endpoints.devices(baseURL: baseURL)
        url = url.appending(queryItems: [URLQueryItem(name: "app_api_token", value: appApiToken)])

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        return try await perform(urlRequest)
    }

    // MARK: - Private

    private func perform<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CriticError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CriticError.networkError("Invalid response")
        }

        try mapHTTPError(statusCode: httpResponse.statusCode, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CriticError.decodingFailed
        }
    }

    private func mapHTTPError(statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200..<300:
            return
        case 401:
            throw CriticError.unauthorized
        case 403:
            throw CriticError.forbidden
        case 404:
            throw CriticError.notFound
        case 400:
            let message = extractErrorMessage(from: data)
            throw CriticError.badRequest(message)
        case 422:
            let message = extractErrorMessage(from: data)
            throw CriticError.validationFailed(message)
        default:
            throw CriticError.unexpectedStatusCode(statusCode)
        }
    }

    private func extractErrorMessage(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data) {
            if let array = json as? [String], let first = array.first {
                return first
            }
            if let dict = json as? [String: Any], let error = dict["error"] as? String {
                return error
            }
        }
        return String(data: data, encoding: .utf8) ?? "Unknown error"
    }

    private func addDeviceStatusFields(to formData: inout MultipartFormData, status: DeviceStatus) {
        if let v = status.batteryCharging { formData.addField(name: "device_status[battery_charging]", value: String(v)) }
        if let v = status.batteryLevel { formData.addField(name: "device_status[battery_level]", value: String(v)) }
        if let v = status.batteryHealth { formData.addField(name: "device_status[battery_health]", value: v) }
        if let v = status.diskFree { formData.addField(name: "device_status[disk_free]", value: String(v)) }
        if let v = status.diskPlatform { formData.addField(name: "device_status[disk_platform]", value: String(v)) }
        if let v = status.diskTotal { formData.addField(name: "device_status[disk_total]", value: String(v)) }
        if let v = status.diskUsable { formData.addField(name: "device_status[disk_usable]", value: String(v)) }
        if let v = status.memoryActive { formData.addField(name: "device_status[memory_active]", value: String(v)) }
        if let v = status.memoryFree { formData.addField(name: "device_status[memory_free]", value: String(v)) }
        if let v = status.memoryInactive { formData.addField(name: "device_status[memory_inactive]", value: String(v)) }
        if let v = status.memoryPurgable { formData.addField(name: "device_status[memory_purgable]", value: String(v)) }
        if let v = status.memoryTotal { formData.addField(name: "device_status[memory_total]", value: String(v)) }
        if let v = status.memoryWired { formData.addField(name: "device_status[memory_wired]", value: String(v)) }
        if let v = status.networkCellConnected { formData.addField(name: "device_status[network_cell_connected]", value: String(v)) }
        if let v = status.networkCellSignalBars { formData.addField(name: "device_status[network_cell_signal_bars]", value: String(v)) }
        if let v = status.networkWifiConnected { formData.addField(name: "device_status[network_wifi_connected]", value: String(v)) }
        if let v = status.networkWifiSignalBars { formData.addField(name: "device_status[network_wifi_signal_bars]", value: String(v)) }
    }
}
