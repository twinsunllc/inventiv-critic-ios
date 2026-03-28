import Testing
import Foundation
@testable import Critic

/// Integration tests that demonstrate the full Critic SDK flow:
/// initialize (ping) -> submit a bug report.
///
/// By default these tests are disabled because they require a running Critic
/// server. To run them against a local instance:
///
///     CRITIC_BASE_URL=http://localhost:8000 \
///     CRITIC_API_TOKEN=puZh4G2f1j9jwFSDrPus2ZtN \
///     swift test --filter CriticIntegrationTests
///
/// The tests use the CriticAPI actor directly so they work on macOS without
/// UIKit (the high-level `Critic.shared.initialize()` requires UIKit for
/// device info collection).
@Suite(.disabled("Requires a running Critic server; set CRITIC_BASE_URL and CRITIC_API_TOKEN to enable"),
       .tags(.integration))
struct CriticIntegrationTests {

    /// Reads configuration from environment variables.
    private var baseURL: URL {
        let urlString = ProcessInfo.processInfo.environment["CRITIC_BASE_URL"] ?? "http://localhost:8000"
        return URL(string: urlString)!
    }

    private var apiToken: String {
        ProcessInfo.processInfo.environment["CRITIC_API_TOKEN"] ?? "puZh4G2f1j9jwFSDrPus2ZtN"
    }

    // MARK: - Step 1: Ping (register device + app install)

    @Test func pingRegistersAppInstall() async throws {
        let api = CriticAPI(baseURL: baseURL, apiToken: apiToken)

        let pingRequest = PingRequest(
            apiToken: apiToken,
            app: AppInfo(
                name: "CriticIntegrationTest",
                package: "io.inventiv.critic.integration-test",
                platform: "iOS",
                version: AppVersionInfo(code: "1", name: "1.0.0")
            ),
            device: DeviceInfoData(
                identifier: UUID().uuidString,
                manufacturer: "Apple",
                model: "macOS-test",
                networkCarrier: "None",
                platform: "iOS",
                platformVersion: ProcessInfo.processInfo.operatingSystemVersionString
            )
        )

        let appInstall = try await api.ping(pingRequest)

        #expect(!appInstall.id.isEmpty, "Ping should return a non-empty app install ID")
        print("[Integration] Ping succeeded. App install ID: \(appInstall.id)")
    }

    // MARK: - Step 2: Submit a bug report

    @Test func submitBugReport() async throws {
        let api = CriticAPI(baseURL: baseURL, apiToken: apiToken)

        // First, ping to get an app install ID
        let pingRequest = PingRequest(
            apiToken: apiToken,
            app: AppInfo(
                name: "CriticIntegrationTest",
                package: "io.inventiv.critic.integration-test",
                platform: "iOS",
                version: AppVersionInfo(code: "1", name: "1.0.0")
            ),
            device: DeviceInfoData(
                identifier: UUID().uuidString,
                manufacturer: "Apple",
                model: "macOS-test",
                networkCarrier: "None",
                platform: "iOS",
                platformVersion: ProcessInfo.processInfo.operatingSystemVersionString
            )
        )

        let appInstall = try await api.ping(pingRequest)
        print("[Integration] Ping succeeded. App install ID: \(appInstall.id)")

        // Now submit a bug report
        let reportInput = BugReportInput(
            description: "Integration test bug report from swift test",
            metadata: ["source": "integration-test", "timestamp": ISO8601DateFormatter().string(from: Date())],
            stepsToReproduce: "1. Run swift test\n2. Observe this report",
            userIdentifier: "test-runner@localhost"
        )

        let bugReport = try await api.createBugReport(
            report: reportInput,
            appInstallId: appInstall.id
        )

        #expect(!bugReport.id.isEmpty, "Bug report should have a non-empty ID")
        #expect(bugReport.description == reportInput.description)
        print("[Integration] Bug report submitted. ID: \(bugReport.id)")
    }

    // MARK: - Full flow: ping + submit with attachment

    @Test func fullFlowWithAttachment() async throws {
        let api = CriticAPI(baseURL: baseURL, apiToken: apiToken)

        // Ping
        let appInstall = try await api.ping(PingRequest(
            apiToken: apiToken,
            app: AppInfo(
                name: "CriticIntegrationTest",
                package: "io.inventiv.critic.integration-test",
                version: AppVersionInfo(code: "1", name: "1.0.0")
            ),
            device: DeviceInfoData(
                identifier: UUID().uuidString,
                manufacturer: "Apple",
                model: "macOS-test",
                networkCarrier: "None",
                platformVersion: ProcessInfo.processInfo.operatingSystemVersionString
            )
        ))

        // Submit with a text file attachment
        let attachmentData = Data("This is a test log file.\nLine 2.\n".utf8)
        let bugReport = try await api.createBugReport(
            report: BugReportInput(
                description: "Integration test with attachment"
            ),
            appInstallId: appInstall.id,
            attachments: [(filename: "test-log.txt", mimeType: "text/plain", data: attachmentData)]
        )

        #expect(!bugReport.id.isEmpty)
        print("[Integration] Full flow succeeded. Report ID: \(bugReport.id)")
    }
}

extension Tag {
    @Tag static var integration: Self
}
