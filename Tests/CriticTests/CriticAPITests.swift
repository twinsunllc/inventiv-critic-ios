import Testing
import Foundation
@testable import Critic

// MARK: - Mock URLProtocol

/// A URLProtocol subclass that intercepts network requests for testing.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    /// Handler that provides (response, data, error) for each request.
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Captured requests for assertion.
    nonisolated(unsafe) static var capturedRequests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.capturedRequests.append(request)

        guard let handler = Self.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }
}

/// Creates a URLSession configured with MockURLProtocol.
private func mockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

/// Creates a CriticAPI instance using the mock session.
private func mockAPI(baseURL: String = "https://critic.test.io", apiToken: String = "test-token") -> CriticAPI {
    CriticAPI(baseURL: URL(string: baseURL)!, apiToken: apiToken, session: mockSession())
}

// MARK: - Ping Request Construction Tests

@Test func pingRequestSendsCorrectHTTPMethod() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let body = Data("""
        {"app_install": {"id": "install-123"}}
        """.utf8)
        return (response, body)
    }

    let api = mockAPI()
    let pingRequest = PingRequest(
        apiToken: "test-token",
        app: AppInfo(name: "App", package: "com.test", version: AppVersionInfo(code: "1", name: "1.0")),
        device: DeviceInfoData(identifier: "dev-id", manufacturer: "Apple", model: "iPhone15,2", networkCarrier: "Verizon", platformVersion: "17.0")
    )

    _ = try await api.ping(pingRequest)

    let captured = MockURLProtocol.capturedRequests.first
    #expect(captured?.httpMethod == "POST")
    #expect(captured?.url?.absoluteString == "https://critic.test.io/api/v3/ping")
    #expect(captured?.value(forHTTPHeaderField: "Content-Type") == "application/json")
}

@Test func pingRequestBodyContainsCorrectFields() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"app_install": {"id": "install-456"}}
        """.utf8))
    }

    let api = mockAPI(apiToken: "org-token-abc")
    let pingRequest = PingRequest(
        apiToken: "org-token-abc",
        app: AppInfo(name: "MyApp", package: "com.myapp", version: AppVersionInfo(code: "42", name: "2.1.0")),
        device: DeviceInfoData(identifier: "dev-xyz", manufacturer: "Apple", model: "iPad14,1", networkCarrier: "AT&T", platformVersion: "16.5")
    )

    _ = try await api.ping(pingRequest)

    let captured = MockURLProtocol.capturedRequests.first
    let bodyData = captured?.httpBody ?? Data()
    let body = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]

    #expect(body["api_token"] as? String == "org-token-abc")
    let app = body["app"] as! [String: Any]
    #expect(app["name"] as? String == "MyApp")
    #expect(app["package"] as? String == "com.myapp")
    let version = app["version"] as! [String: Any]
    #expect(version["code"] as? String == "42")
}

@Test func pingResponseParsesAppInstallId() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"app_install": {"id": "uuid-parsed-correctly"}}
        """.utf8))
    }

    let api = mockAPI()
    let result = try await api.ping(PingRequest(
        apiToken: "t",
        app: AppInfo(name: "A", package: "p", version: AppVersionInfo(code: "1", name: "1")),
        device: DeviceInfoData(identifier: "i", manufacturer: "Apple", model: "m", networkCarrier: "c", platformVersion: "v")
    ))

    #expect(result.id == "uuid-parsed-correctly")
}

// MARK: - Bug Report Request Construction Tests

@Test func createBugReportSendsMultipartPOST() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"id": "br-new", "description": "Test bug"}
        """.utf8))
    }

    let api = mockAPI()
    let input = BugReportInput(description: "Test bug", metadata: ["env": "staging"], stepsToReproduce: "1. Open app", userIdentifier: "user@test.com")

    _ = try await api.createBugReport(report: input, appInstallId: "install-id")

    let captured = MockURLProtocol.capturedRequests.first
    #expect(captured?.httpMethod == "POST")
    #expect(captured?.url?.absoluteString == "https://critic.test.io/api/v3/bug_reports")
    let contentType = captured?.value(forHTTPHeaderField: "Content-Type") ?? ""
    #expect(contentType.hasPrefix("multipart/form-data; boundary="))

    let bodyString = String(data: captured?.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(bodyString.contains("name=\"api_token\""))
    #expect(bodyString.contains("test-token"))
    #expect(bodyString.contains("name=\"app_install[id]\""))
    #expect(bodyString.contains("install-id"))
    #expect(bodyString.contains("name=\"bug_report[description]\""))
    #expect(bodyString.contains("Test bug"))
    #expect(bodyString.contains("name=\"bug_report[steps_to_reproduce]\""))
    #expect(bodyString.contains("1. Open app"))
    #expect(bodyString.contains("name=\"bug_report[user_identifier]\""))
    #expect(bodyString.contains("user@test.com"))
    #expect(bodyString.contains("name=\"bug_report[metadata]\""))
}

@Test func createBugReportWithAttachments() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"id": "br-attach"}
        """.utf8))
    }

    let api = mockAPI()
    let input = BugReportInput(description: "With file")
    let fileData = Data("screenshot content".utf8)

    _ = try await api.createBugReport(
        report: input,
        appInstallId: "inst-1",
        attachments: [(filename: "screenshot.png", mimeType: "image/png", data: fileData)]
    )

    let bodyString = String(data: MockURLProtocol.capturedRequests.first?.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(bodyString.contains("name=\"bug_report[attachments][]\""))
    #expect(bodyString.contains("filename=\"screenshot.png\""))
    #expect(bodyString.contains("Content-Type: image/png"))
    #expect(bodyString.contains("screenshot content"))
}

@Test func createBugReportParsesResponse() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {
            "id": "br-full",
            "description": "Full report",
            "steps_to_reproduce": "Step 1",
            "user_identifier": "jane@example.com",
            "created_at": "2026-03-27T10:00:00Z",
            "device": {"id": "dev-1", "model": "iPhone15,2"},
            "attachments": [{"id": "att-1", "file_file_name": "log.txt"}]
        }
        """.utf8))
    }

    let api = mockAPI()
    let result = try await api.createBugReport(report: BugReportInput(description: "Full report"), appInstallId: "inst")

    #expect(result.id == "br-full")
    #expect(result.description == "Full report")
    #expect(result.stepsToReproduce == "Step 1")
    #expect(result.userIdentifier == "jane@example.com")
    #expect(result.device?.model == "iPhone15,2")
    #expect(result.attachments?.first?.fileFileName == "log.txt")
}

// MARK: - List Bug Reports Tests

@Test func listBugReportsRequestConstruction() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"count": 0, "current_page": 1, "total_pages": 0, "bug_reports": []}
        """.utf8))
    }

    let api = mockAPI()
    _ = try await api.listBugReports(appApiToken: "app-tok", archived: true, deviceId: "dev-1", since: "2026-01-01")

    let captured = MockURLProtocol.capturedRequests.first
    #expect(captured?.httpMethod == "GET")
    let urlString = captured?.url?.absoluteString ?? ""
    #expect(urlString.contains("app_api_token=app-tok"))
    #expect(urlString.contains("archived=true"))
    #expect(urlString.contains("device_id=dev-1"))
    #expect(urlString.contains("since=2026-01-01"))
}

@Test func listBugReportsParsesPaginatedResponse() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {
            "count": 2,
            "current_page": 1,
            "total_pages": 1,
            "bug_reports": [
                {"id": "br-1", "description": "First"},
                {"id": "br-2", "description": "Second"}
            ]
        }
        """.utf8))
    }

    let api = mockAPI()
    let result = try await api.listBugReports(appApiToken: "tok")

    #expect(result.count == 2)
    #expect(result.currentPage == 1)
    #expect(result.totalPages == 1)
    #expect(result.items.count == 2)
    #expect(result.items[0].id == "br-1")
    #expect(result.items[1].description == "Second")
}

// MARK: - Get Bug Report Tests

@Test func getBugReportRequestConstruction() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"id": "br-uuid-123", "description": "Single report"}
        """.utf8))
    }

    let api = mockAPI()
    let result = try await api.getBugReport(id: "br-uuid-123", appApiToken: "app-tok")

    let captured = MockURLProtocol.capturedRequests.first
    #expect(captured?.httpMethod == "GET")
    #expect(captured?.url?.absoluteString.contains("bug_reports/br-uuid-123") == true)
    #expect(captured?.url?.absoluteString.contains("app_api_token=app-tok") == true)
    #expect(result.id == "br-uuid-123")
    #expect(result.description == "Single report")
}

// MARK: - List Devices Tests

@Test func listDevicesRequestConstruction() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {
            "count": 1,
            "current_page": 1,
            "total_pages": 1,
            "devices": [{"id": "dev-1", "model": "iPhone15,2", "platform": "iOS"}]
        }
        """.utf8))
    }

    let api = mockAPI()
    let result = try await api.listDevices(appApiToken: "app-tok")

    let captured = MockURLProtocol.capturedRequests.first
    #expect(captured?.httpMethod == "GET")
    #expect(captured?.url?.absoluteString.contains("devices") == true)
    #expect(captured?.url?.absoluteString.contains("app_api_token=app-tok") == true)
    #expect(result.items.count == 1)
    #expect(result.items[0].model == "iPhone15,2")
}

// MARK: - Error Handling Tests (HTTP Status Codes)

@Test func apiReturns401Unauthorized() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        return (response, Data("Unauthorized".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.listBugReports(appApiToken: "bad-token")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .unauthorized)
    }
}

@Test func apiReturns403Forbidden() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 403, httpVersion: nil, headerFields: nil)!
        return (response, Data("Forbidden".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.listBugReports(appApiToken: "tok")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .forbidden)
    }
}

@Test func apiReturns404NotFound() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        return (response, Data("Not Found".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.getBugReport(id: "nonexistent", appApiToken: "tok")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .notFound)
    }
}

@Test func apiReturns422ValidationFailed() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 422, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"error": "Description is required"}
        """.utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.createBugReport(report: BugReportInput(description: ""), appInstallId: "inst")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .validationFailed("Description is required"))
    }
}

@Test func apiReturns400BadRequest() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        ["Invalid api_token parameter"]
        """.utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.createBugReport(report: BugReportInput(description: "test"), appInstallId: "inst")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .badRequest("Invalid api_token parameter"))
    }
}

@Test func apiReturns500UnexpectedStatusCode() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        return (response, Data("Internal Server Error".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.listDevices(appApiToken: "tok")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .unexpectedStatusCode(500))
    }
}

@Test func apiReturnsInvalidJSONThrowsDecodingFailed() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("not valid json {{{".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.listBugReports(appApiToken: "tok")
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .decodingFailed)
    }
}

// MARK: - UUID String Handling Tests

@Test func modelIdsAreDecodedAsStrings() throws {
    // All IDs come as UUID strings from the API; verify they're handled correctly
    let json = """
    {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "description": "UUID test",
        "device": {"id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8", "model": "iPhone"},
        "app": {"id": "f47ac10b-58cc-4372-a567-0e02b2c3d479", "name": "TestApp"},
        "attachments": [{"id": "a9b1c2d3-e4f5-6789-abcd-ef0123456789"}]
    }
    """
    let report = try JSONDecoder().decode(BugReport.self, from: Data(json.utf8))
    #expect(report.id == "550e8400-e29b-41d4-a716-446655440000")
    #expect(report.device?.id == "6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    #expect(report.app?.id == "f47ac10b-58cc-4372-a567-0e02b2c3d479")
    #expect(report.attachments?.first?.id == "a9b1c2d3-e4f5-6789-abcd-ef0123456789")
}

@Test func appInstallIdIsUUIDString() throws {
    let json = """
    {"id": "c56a4180-65aa-42ec-a945-5fd21dec0538"}
    """
    let install = try JSONDecoder().decode(AppInstall.self, from: Data(json.utf8))
    #expect(install.id == "c56a4180-65aa-42ec-a945-5fd21dec0538")
}

@Test func nonStandardIdFormatsDecodeCorrectly() throws {
    // The API may return non-UUID string IDs in some cases
    let json = """
    {"id": "simple-string-id", "name": "Test"}
    """
    let app = try JSONDecoder().decode(App.self, from: Data(json.utf8))
    #expect(app.id == "simple-string-id")
}

// MARK: - Device Status Fields in Bug Report Request

@Test func createBugReportIncludesDeviceStatus() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"id": "br-ds"}
        """.utf8))
    }

    let api = mockAPI()
    let status = DeviceStatus(batteryCharging: true, batteryLevel: 85, diskFree: 1_000_000, memoryTotal: 8_000_000)

    _ = try await api.createBugReport(
        report: BugReportInput(description: "With status"),
        appInstallId: "inst",
        deviceStatus: status
    )

    let bodyString = String(data: MockURLProtocol.capturedRequests.first?.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(bodyString.contains("device_status[battery_charging]"))
    #expect(bodyString.contains("true"))
    #expect(bodyString.contains("device_status[battery_level]"))
    #expect(bodyString.contains("85"))
    #expect(bodyString.contains("device_status[disk_free]"))
    #expect(bodyString.contains("device_status[memory_total]"))
}

// MARK: - Error Message Extraction Tests

@Test func errorMessageFromJsonDict() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 422, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        {"error": "Validation failed: description can't be blank"}
        """.utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.createBugReport(report: BugReportInput(description: ""), appInstallId: "inst")
        #expect(Bool(false))
    } catch let error as CriticError {
        #expect(error == .validationFailed("Validation failed: description can't be blank"))
    }
}

@Test func errorMessageFromJsonArray() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        return (response, Data("""
        ["First error message", "Second error"]
        """.utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.createBugReport(report: BugReportInput(description: "test"), appInstallId: "inst")
        #expect(Bool(false))
    } catch let error as CriticError {
        #expect(error == .badRequest("First error message"))
    }
}

@Test func errorMessageFromPlainText() async throws {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(url: URL(string: "https://critic.test.io")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        return (response, Data("Plain text error".utf8))
    }

    let api = mockAPI()
    do {
        _ = try await api.createBugReport(report: BugReportInput(description: "test"), appInstallId: "inst")
        #expect(Bool(false))
    } catch let error as CriticError {
        #expect(error == .badRequest("Plain text error"))
    }
}
