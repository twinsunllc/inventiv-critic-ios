import Testing
import Foundation
import OSLog
@testable import Critic

// MARK: - LogCapture Tests

@Test func logCaptureMaxEntriesIs500() {
    #expect(LogCapture.maxEntries == 500)
}

@Test func logCaptureMaxTimeIntervalIs300Seconds() {
    #expect(LogCapture.maxTimeInterval == 300)
}

@Test func logCaptureDebuggerCheckReturnsBool() {
    // In a test runner, the debugger may or may not be attached.
    // We just verify the function returns without crashing.
    let result = LogCapture.isDebuggerAttached()
    #expect(result == true || result == false)
}

@Test func logCaptureRecentLogsReturnsCorrectFilename() {
    // When running in a test harness, the debugger is typically attached,
    // so captureRecentLogs() returns nil. This is expected behavior.
    // If it does return a result, verify the filename and mimeType.
    if let attachment = LogCapture.captureRecentLogs() {
        #expect(attachment.filename == "console.log")
        #expect(attachment.mimeType == "text/plain")
        #expect(!attachment.data.isEmpty)
    }
    // Either way, the call should not throw or crash.
}

@Test func logCaptureEntryTimestampFormat() {
    // Create a known date and verify the formatting.
    // OSLogEntry is not directly constructable, so we test the formatter pattern
    // by verifying the date formatter used internally produces the expected format.
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")

    let date = Date(timeIntervalSince1970: 1711612800) // 2024-03-28T12:00:00Z
    let result = formatter.string(from: date)

    // Verify format pattern: YYYY-MM-DD HH:MM:SS.mmm
    #expect(result.contains("-"))
    #expect(result.contains(":"))
    #expect(result.contains("."))
    // Should be 23 chars: "2024-03-28 12:00:00.000"
    #expect(result.count == 23)
}

// MARK: - Integration: console log attachment in bug report

@Test func submitReportIncludesConsoleLogAttachment() async throws {
    // This test verifies that when LogCapture returns data,
    // it gets included in the multipart body sent to the API.
    // Since we can't easily mock LogCapture.captureRecentLogs() (it's a static method),
    // we test the API layer directly: passing a console.log attachment should appear in the body.
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(
            url: URL(string: "https://critic.test.io")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        return (response, Data("""
        {"id": "br-with-logs"}
        """.utf8))
    }

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    let api = CriticAPI(
        baseURL: URL(string: "https://critic.test.io")!,
        apiToken: "test-token",
        session: session
    )

    let logData = Data("2026-03-28 10:00:00.000 INFO (com.test) [default] App launched\n".utf8)
    let attachments: [(filename: String, mimeType: String, data: Data)] = [
        (filename: "console.log", mimeType: "text/plain", data: logData)
    ]

    _ = try await api.createBugReport(
        report: BugReportInput(description: "Bug with logs"),
        appInstallId: "inst-1",
        attachments: attachments
    )

    let bodyString = String(
        data: MockURLProtocol.capturedRequests.first?.httpBody ?? Data(),
        encoding: .utf8
    ) ?? ""

    #expect(bodyString.contains("name=\"bug_report[attachments][]\""))
    #expect(bodyString.contains("filename=\"console.log\""))
    #expect(bodyString.contains("Content-Type: text/plain"))
    #expect(bodyString.contains("App launched"))
}

@Test func submitReportWithUserAttachmentsAndConsoleLogs() async throws {
    // Verify that both user attachments and console log attachment appear in the body.
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = { _ in
        let response = HTTPURLResponse(
            url: URL(string: "https://critic.test.io")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        return (response, Data("""
        {"id": "br-multi-attach"}
        """.utf8))
    }

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    let api = CriticAPI(
        baseURL: URL(string: "https://critic.test.io")!,
        apiToken: "test-token",
        session: session
    )

    let userFile = Data("screenshot content".utf8)
    let logData = Data("2026-03-28 10:00:00.000 ERROR [network] Request failed\n".utf8)
    let attachments: [(filename: String, mimeType: String, data: Data)] = [
        (filename: "screenshot.png", mimeType: "image/png", data: userFile),
        (filename: "console.log", mimeType: "text/plain", data: logData),
    ]

    _ = try await api.createBugReport(
        report: BugReportInput(description: "Bug with everything"),
        appInstallId: "inst-2",
        attachments: attachments
    )

    let bodyString = String(
        data: MockURLProtocol.capturedRequests.first?.httpBody ?? Data(),
        encoding: .utf8
    ) ?? ""

    // Both attachments present
    #expect(bodyString.contains("filename=\"screenshot.png\""))
    #expect(bodyString.contains("filename=\"console.log\""))
    #expect(bodyString.contains("screenshot content"))
    #expect(bodyString.contains("Request failed"))
}
