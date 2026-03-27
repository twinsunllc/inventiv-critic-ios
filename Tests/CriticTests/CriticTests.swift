import Testing
import Foundation
@testable import Critic

// MARK: - Model Tests

@Test func appDecoding() throws {
    let json = """
    {"id": "abc-123", "name": "TestApp", "platform": "iOS"}
    """
    let app = try JSONDecoder().decode(App.self, from: Data(json.utf8))
    #expect(app.id == "abc-123")
    #expect(app.name == "TestApp")
    #expect(app.platform == "iOS")
}

@Test func appDecodingMinimal() throws {
    let json = """
    {"id": "abc-123"}
    """
    let app = try JSONDecoder().decode(App.self, from: Data(json.utf8))
    #expect(app.id == "abc-123")
    #expect(app.name == nil)
    #expect(app.platform == nil)
}

@Test func appInstallDecoding() throws {
    let json = """
    {"id": "install-uuid-456"}
    """
    let install = try JSONDecoder().decode(AppInstall.self, from: Data(json.utf8))
    #expect(install.id == "install-uuid-456")
}

@Test func appVersionDecoding() throws {
    let json = """
    {"id": "ver-uuid", "code": "42", "name": "2.1.0"}
    """
    let version = try JSONDecoder().decode(AppVersion.self, from: Data(json.utf8))
    #expect(version.id == "ver-uuid")
    #expect(version.code == "42")
    #expect(version.name == "2.1.0")
}

@Test func attachmentDecodingWithSnakeCaseKeys() throws {
    let json = """
    {
        "id": "att-uuid",
        "file_file_name": "screenshot.png",
        "file_file_size": 12345,
        "file_content_type": "image/png",
        "file_updated_at": "2026-01-01T00:00:00Z",
        "url": "https://example.com/screenshot.png"
    }
    """
    let att = try JSONDecoder().decode(Attachment.self, from: Data(json.utf8))
    #expect(att.id == "att-uuid")
    #expect(att.fileFileName == "screenshot.png")
    #expect(att.fileFileSize == 12345)
    #expect(att.fileContentType == "image/png")
    #expect(att.fileUpdatedAt == "2026-01-01T00:00:00Z")
    #expect(att.url == "https://example.com/screenshot.png")
}

@Test func bugReportDecodingFull() throws {
    let json = """
    {
        "id": "br-uuid",
        "description": "App crashes on launch",
        "metadata": "{\\"key\\":\\"value\\"}",
        "steps_to_reproduce": "1. Open app\\n2. See crash",
        "user_identifier": "user@example.com",
        "created_at": "2026-03-27T10:00:00Z",
        "updated_at": "2026-03-27T11:00:00Z",
        "device": {"id": "dev-uuid", "model": "iPhone15,2"},
        "device_status": {"battery_level": 85, "battery_charging": true},
        "app_version": {"code": "10", "name": "1.5.0"},
        "app": {"id": "app-uuid", "name": "TestApp"},
        "attachments": [{"id": "att-uuid"}]
    }
    """
    let report = try JSONDecoder().decode(BugReport.self, from: Data(json.utf8))
    #expect(report.id == "br-uuid")
    #expect(report.description == "App crashes on launch")
    #expect(report.stepsToReproduce == "1. Open app\n2. See crash")
    #expect(report.userIdentifier == "user@example.com")
    #expect(report.device?.model == "iPhone15,2")
    #expect(report.deviceStatus?.batteryLevel == 85)
    #expect(report.deviceStatus?.batteryCharging == true)
    #expect(report.appVersion?.code == "10")
    #expect(report.app?.name == "TestApp")
    #expect(report.attachments?.count == 1)
}

@Test func bugReportDecodingMinimal() throws {
    let json = """
    {"id": "br-uuid"}
    """
    let report = try JSONDecoder().decode(BugReport.self, from: Data(json.utf8))
    #expect(report.id == "br-uuid")
    #expect(report.description == nil)
    #expect(report.device == nil)
    #expect(report.attachments == nil)
}

@Test func deviceDecodingWithSnakeCaseKeys() throws {
    let json = """
    {
        "id": "dev-uuid",
        "identifier": "AABB-1122",
        "manufacturer": "Apple",
        "model": "iPhone15,2",
        "network_carrier": "Verizon",
        "platform": "iOS",
        "platform_version": "17.0",
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-03-01T00:00:00Z"
    }
    """
    let device = try JSONDecoder().decode(Device.self, from: Data(json.utf8))
    #expect(device.id == "dev-uuid")
    #expect(device.identifier == "AABB-1122")
    #expect(device.manufacturer == "Apple")
    #expect(device.model == "iPhone15,2")
    #expect(device.networkCarrier == "Verizon")
    #expect(device.platform == "iOS")
    #expect(device.platformVersion == "17.0")
    #expect(device.createdAt == "2026-01-01T00:00:00Z")
    #expect(device.updatedAt == "2026-03-01T00:00:00Z")
}

@Test func deviceStatusDecodingAllFields() throws {
    let json = """
    {
        "id": "ds-uuid",
        "battery_charging": true,
        "battery_level": 85,
        "battery_health": "Good",
        "disk_free": 1073741824,
        "disk_platform": 2147483648,
        "disk_total": 137438953472,
        "disk_usable": 128849018880,
        "memory_active": 1073741824,
        "memory_free": 536870912,
        "memory_inactive": 536870912,
        "memory_purgable": 2147483648,
        "memory_total": 8589934592,
        "memory_wired": 134217728,
        "metadata": "{}",
        "network_cell_connected": true,
        "network_cell_signal_bars": 3,
        "network_wifi_connected": true,
        "network_wifi_signal_bars": 2
    }
    """
    let status = try JSONDecoder().decode(DeviceStatus.self, from: Data(json.utf8))
    #expect(status.id == "ds-uuid")
    #expect(status.batteryCharging == true)
    #expect(status.batteryLevel == 85)
    #expect(status.batteryHealth == "Good")
    #expect(status.diskFree == 1_073_741_824)
    #expect(status.diskTotal == 137_438_953_472)
    #expect(status.memoryTotal == 8_589_934_592)
    #expect(status.networkCellConnected == true)
    #expect(status.networkCellSignalBars == 3)
    #expect(status.networkWifiConnected == true)
    #expect(status.networkWifiSignalBars == 2)
}

@Test func deviceStatusDecodingAllNil() throws {
    let json = """
    {}
    """
    let status = try JSONDecoder().decode(DeviceStatus.self, from: Data(json.utf8))
    #expect(status.id == nil)
    #expect(status.batteryLevel == nil)
    #expect(status.diskFree == nil)
    #expect(status.memoryTotal == nil)
}

// MARK: - PaginatedResponse Tests

@Test func paginatedResponseBugReportsDecoding() throws {
    let json = """
    {
        "count": 2,
        "current_page": 1,
        "total_pages": 1,
        "bug_reports": [
            {"id": "br-1", "description": "Bug 1"},
            {"id": "br-2", "description": "Bug 2"}
        ]
    }
    """
    let response = try JSONDecoder().decode(PaginatedResponse<BugReport>.self, from: Data(json.utf8))
    #expect(response.count == 2)
    #expect(response.currentPage == 1)
    #expect(response.totalPages == 1)
    #expect(response.items.count == 2)
    #expect(response.items[0].id == "br-1")
    #expect(response.items[1].id == "br-2")
}

@Test func paginatedResponseDevicesDecoding() throws {
    let json = """
    {
        "count": 1,
        "current_page": 1,
        "total_pages": 1,
        "devices": [
            {"id": "dev-1", "model": "iPhone15,2"}
        ]
    }
    """
    let response = try JSONDecoder().decode(PaginatedResponse<Device>.self, from: Data(json.utf8))
    #expect(response.count == 1)
    #expect(response.items.count == 1)
    #expect(response.items[0].id == "dev-1")
    #expect(response.items[0].model == "iPhone15,2")
}

@Test func paginatedResponseEmptyItems() throws {
    let json = """
    {
        "count": 0,
        "current_page": 1,
        "total_pages": 0
    }
    """
    let response = try JSONDecoder().decode(PaginatedResponse<BugReport>.self, from: Data(json.utf8))
    #expect(response.count == 0)
    #expect(response.items.isEmpty)
}

@Test func paginatedResponseBugReportsRoundTrip() throws {
    let original = PaginatedResponse<BugReport>(
        count: 1,
        currentPage: 1,
        totalPages: 1,
        items: [BugReport(id: "br-1", description: "Test")]
    )
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(PaginatedResponse<BugReport>.self, from: data)
    #expect(decoded.count == original.count)
    #expect(decoded.currentPage == original.currentPage)
    #expect(decoded.totalPages == original.totalPages)
    #expect(decoded.items.count == 1)
    #expect(decoded.items[0].id == "br-1")
}

@Test func paginatedResponseDevicesRoundTrip() throws {
    let original = PaginatedResponse<Device>(
        count: 2,
        currentPage: 1,
        totalPages: 1,
        items: [
            Device(id: "dev-1", model: "iPhone15,2"),
            Device(id: "dev-2", model: "iPad14,1")
        ]
    )
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(PaginatedResponse<Device>.self, from: data)
    #expect(decoded.count == 2)
    #expect(decoded.items.count == 2)
    #expect(decoded.items[0].id == "dev-1")
    #expect(decoded.items[1].model == "iPad14,1")
}

@Test func paginatedResponseUnknownTypeDecodesViaFallback() throws {
    // AppVersion doesn't conform to PaginatedItemKey, so the decoder
    // should fall back to trying all non-metadata keys.
    let json = """
    {
        "count": 1,
        "current_page": 1,
        "total_pages": 1,
        "app_versions": [
            {"id": "ver-1", "code": "10", "name": "1.0.0"}
        ]
    }
    """
    let response = try JSONDecoder().decode(PaginatedResponse<AppVersion>.self, from: Data(json.utf8))
    #expect(response.count == 1)
    #expect(response.items.count == 1)
    #expect(response.items[0].id == "ver-1")
}

// MARK: - PingRequest Tests

@Test func pingRequestEncoding() throws {
    let request = PingRequest(
        apiToken: "org-token-123",
        app: AppInfo(
            name: "TestApp",
            package: "com.test.app",
            version: AppVersionInfo(code: "1", name: "1.0.0")
        ),
        device: DeviceInfoData(
            identifier: "device-id",
            manufacturer: "Apple",
            model: "iPhone15,2",
            networkCarrier: "Verizon",
            platformVersion: "17.0"
        )
    )

    let data = try JSONEncoder().encode(request)
    let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    #expect(dict["api_token"] as? String == "org-token-123")

    let app = dict["app"] as! [String: Any]
    #expect(app["name"] as? String == "TestApp")
    #expect(app["package"] as? String == "com.test.app")
    #expect(app["platform"] as? String == "iOS")

    let version = app["version"] as! [String: Any]
    #expect(version["code"] as? String == "1")
    #expect(version["name"] as? String == "1.0.0")

    let device = dict["device"] as! [String: Any]
    #expect(device["identifier"] as? String == "device-id")
    #expect(device["manufacturer"] as? String == "Apple")
    #expect(device["network_carrier"] as? String == "Verizon")
    #expect(device["platform_version"] as? String == "17.0")
}

@Test func pingRequestEncodingWithDeviceStatus() throws {
    let status = DeviceStatus(batteryCharging: false, batteryLevel: 80)
    let request = PingRequest(
        apiToken: "tok",
        app: AppInfo(name: "A", package: "p", version: AppVersionInfo(code: "1", name: "1")),
        device: DeviceInfoData(identifier: "i", manufacturer: "Apple", model: "m", networkCarrier: "c", platformVersion: "v"),
        deviceStatus: status
    )

    let data = try JSONEncoder().encode(request)
    let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    let ds = dict["device_status"] as! [String: Any]
    #expect(ds["battery_level"] as? Int == 80)
}

@Test func pingResponseDecoding() throws {
    let json = """
    {"app_install": {"id": "install-uuid-789"}}
    """
    let response = try JSONDecoder().decode(PingResponse.self, from: Data(json.utf8))
    #expect(response.appInstall.id == "install-uuid-789")
}

// MARK: - CriticError Tests

@Test func criticErrorEquality() {
    #expect(CriticError.unauthorized == CriticError.unauthorized)
    #expect(CriticError.forbidden == CriticError.forbidden)
    #expect(CriticError.notFound == CriticError.notFound)
    #expect(CriticError.decodingFailed == CriticError.decodingFailed)
    #expect(CriticError.notInitialized == CriticError.notInitialized)
    #expect(CriticError.unexpectedStatusCode(500) == CriticError.unexpectedStatusCode(500))
    #expect(CriticError.unexpectedStatusCode(500) != CriticError.unexpectedStatusCode(503))
    #expect(CriticError.validationFailed("a") == CriticError.validationFailed("a"))
    #expect(CriticError.validationFailed("a") != CriticError.validationFailed("b"))
    #expect(CriticError.badRequest("x") == CriticError.badRequest("x"))
    #expect(CriticError.networkError("err") == CriticError.networkError("err"))
    #expect(CriticError.unauthorized != CriticError.forbidden)
}

@Test func criticErrorIsError() {
    let error: any Error = CriticError.unauthorized
    #expect(error is CriticError)
}

// MARK: - MultipartFormData Tests

@Test func multipartFormDataContentType() {
    let formData = MultipartFormData(boundary: "test-boundary")
    #expect(formData.contentType == "multipart/form-data; boundary=test-boundary")
}

@Test func multipartFormDataTextField() {
    var formData = MultipartFormData(boundary: "BOUNDARY")
    formData.addField(name: "api_token", value: "my-token")
    let body = String(data: formData.build(), encoding: .utf8)!

    #expect(body.contains("--BOUNDARY\r\n"))
    #expect(body.contains("Content-Disposition: form-data; name=\"api_token\""))
    #expect(body.contains("my-token"))
    #expect(body.contains("--BOUNDARY--"))
}

@Test func multipartFormDataFileField() {
    var formData = MultipartFormData(boundary: "BOUNDARY")
    let fileData = Data("file content".utf8)
    formData.addFile(name: "bug_report[attachments][]", filename: "test.txt", mimeType: "text/plain", data: fileData)
    let body = String(data: formData.build(), encoding: .utf8)!

    #expect(body.contains("Content-Disposition: form-data; name=\"bug_report[attachments][]\"; filename=\"test.txt\""))
    #expect(body.contains("Content-Type: text/plain"))
    #expect(body.contains("file content"))
}

@Test func multipartFormDataMultipleFields() {
    var formData = MultipartFormData(boundary: "B")
    formData.addField(name: "field1", value: "value1")
    formData.addField(name: "field2", value: "value2")
    formData.addFile(name: "file", filename: "f.txt", mimeType: "text/plain", data: Data("data".utf8))
    let body = String(data: formData.build(), encoding: .utf8)!

    let boundaryCount = body.components(separatedBy: "--B\r\n").count - 1
    #expect(boundaryCount == 3) // 3 parts
    #expect(body.hasSuffix("--B--\r\n"))
}

@Test func multipartFormDataEmptyBuild() {
    let formData = MultipartFormData(boundary: "EMPTY")
    let body = String(data: formData.build(), encoding: .utf8)!
    #expect(body == "--EMPTY--\r\n")
}

@Test func multipartFormDataFilenameSanitizesQuotes() {
    var formData = MultipartFormData(boundary: "B")
    let fileData = Data("data".utf8)
    formData.addFile(name: "file", filename: "file\"name.txt", mimeType: "text/plain", data: fileData)
    let body = String(data: formData.build(), encoding: .utf8)!
    #expect(body.contains("filename=\"file\\\"name.txt\""))
    #expect(!body.contains("filename=\"file\"name.txt\""))
}

@Test func multipartFormDataFilenameSanitizesNewlines() {
    var formData = MultipartFormData(boundary: "B")
    let fileData = Data("data".utf8)
    formData.addFile(name: "file", filename: "file\r\nname.txt", mimeType: "text/plain", data: fileData)
    let body = String(data: formData.build(), encoding: .utf8)!
    #expect(body.contains("filename=\"filename.txt\""))
}

// MARK: - Endpoints Tests

@Test func endpointsPingURL() throws {
    let base = try #require(URL(string: "https://critic.inventiv.io"))
    let url = Endpoints.ping(baseURL: base)
    #expect(url.absoluteString == "https://critic.inventiv.io/api/v3/ping")
}

@Test func endpointsBugReportsURL() throws {
    let base = try #require(URL(string: "https://critic.inventiv.io"))
    let url = Endpoints.bugReports(baseURL: base)
    #expect(url.absoluteString == "https://critic.inventiv.io/api/v3/bug_reports")
}

@Test func endpointsBugReportByIdURL() throws {
    let base = try #require(URL(string: "https://critic.inventiv.io"))
    let url = Endpoints.bugReport(baseURL: base, id: "some-uuid")
    #expect(url.absoluteString == "https://critic.inventiv.io/api/v3/bug_reports/some-uuid")
}

@Test func endpointsDevicesURL() throws {
    let base = try #require(URL(string: "https://critic.inventiv.io"))
    let url = Endpoints.devices(baseURL: base)
    #expect(url.absoluteString == "https://critic.inventiv.io/api/v3/devices")
}

// MARK: - CriticAPI Tests

@Test func criticAPIInitialization() throws {
    let url = try #require(URL(string: "https://api.example.com"))
    let api = CriticAPI(baseURL: url, apiToken: "test-token")
    // Actor properties accessed synchronously in test context
    #expect(api != nil)
}

// MARK: - Critic Singleton Tests

@Test func criticSharedInstanceExists() {
    let instance = Critic.shared
    #expect(instance != nil)
}

@Test func criticSharedIsSameInstance() {
    let a = Critic.shared
    let b = Critic.shared
    #expect(a === b)
}

@Test func criticDefaultBaseURL() {
    let critic = Critic.shared
    #expect(critic.baseURL.absoluteString == "https://critic.inventiv.io")
}

@Test func criticNotInitializedThrows() async {
    // Create a fresh instance scenario - shared starts uninitialized
    // submitReport should fail if not initialized
    let input = BugReportInput(description: "test")
    do {
        _ = try await Critic.shared.submitReport(input)
        #expect(Bool(false), "Should have thrown")
    } catch let error as CriticError {
        #expect(error == .notInitialized)
    } catch {
        #expect(Bool(false), "Wrong error type: \(error)")
    }
}

// MARK: - BugReportInput Tests

@Test func bugReportInputInit() {
    let input = BugReportInput(
        description: "Something broke",
        metadata: ["key": "value"],
        stepsToReproduce: "1. Do thing",
        userIdentifier: "user@test.com"
    )
    #expect(input.description == "Something broke")
    #expect(input.metadata?["key"] == "value")
    #expect(input.stepsToReproduce == "1. Do thing")
    #expect(input.userIdentifier == "user@test.com")
}

@Test func bugReportInputMinimal() {
    let input = BugReportInput(description: "Bug")
    #expect(input.description == "Bug")
    #expect(input.metadata == nil)
    #expect(input.stepsToReproduce == nil)
    #expect(input.userIdentifier == nil)
}

// MARK: - Round-trip Encoding/Decoding Tests

@Test func deviceStatusRoundTrip() throws {
    let original = DeviceStatus(
        batteryCharging: true,
        batteryLevel: 75,
        diskFree: 1_000_000,
        memoryTotal: 8_000_000
    )
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(DeviceStatus.self, from: data)
    #expect(decoded == original)
}

@Test func deviceRoundTrip() throws {
    let original = Device(
        id: "uuid",
        identifier: "AABB",
        manufacturer: "Apple",
        model: "iPhone15,2",
        networkCarrier: "T-Mobile",
        platform: "iOS",
        platformVersion: "17.0"
    )
    let data = try JSONEncoder().encode(original)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    // Verify snake_case keys in JSON output
    #expect(json["network_carrier"] as? String == "T-Mobile")
    #expect(json["platform_version"] as? String == "17.0")

    let decoded = try JSONDecoder().decode(Device.self, from: data)
    #expect(decoded == original)
}

@Test func attachmentRoundTrip() throws {
    let original = Attachment(
        id: "att-1",
        fileFileName: "test.png",
        fileFileSize: 1024,
        fileContentType: "image/png"
    )
    let data = try JSONEncoder().encode(original)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    #expect(json["file_file_name"] as? String == "test.png")
    #expect(json["file_file_size"] as? Int == 1024)

    let decoded = try JSONDecoder().decode(Attachment.self, from: data)
    #expect(decoded == original)
}
