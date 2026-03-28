#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import Critic

@main
struct CriticExampleApp: SwiftUI.App {
    /// Configure before running locally: set to your Critic server URL for development,
    /// or leave nil for production. You can also set the CRITIC_BASE_URL environment variable.
    /// Example: URL(string: "http://localhost:8000")
    private static let customBaseURL: URL? = nil

    /// Configure before running locally: replace with your API token from
    /// https://critic.inventiv.io/products, or set the CRITIC_API_TOKEN environment variable.
    private static let apiToken = ""

    init() {
        Task {
            do {
                try await Critic.shared.initialize(
                    apiToken: Self.apiToken,
                    baseURL: Self.customBaseURL
                )
                print("Critic SDK initialized successfully")
            } catch {
                print("Failed to initialize Critic: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedback = false
    @State private var lastReportId: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Critic SDK Example")
                    .font(.title)

                if let reportId = lastReportId {
                    Text("Last report: \(reportId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Send Feedback") {
                    showFeedback = true
                }
                .buttonStyle(.borderedProminent)

                Button("Submit Programmatically") {
                    Task { await submitReport() }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Example")
            .sheet(isPresented: $showFeedback) {
                FeedbackView(
                    onSubmit: { report in
                        lastReportId = report.id
                        showFeedback = false
                    },
                    onCancel: {
                        showFeedback = false
                    }
                )
            }
        }
    }

    private func submitReport() async {
        let input = BugReportInput(
            description: "Test report from example app",
            metadata: ["source": "example"],
            stepsToReproduce: "1. Opened example app\n2. Tapped Submit"
        )

        do {
            let report = try await Critic.shared.submitReport(input)
            lastReportId = report.id
            print("Report submitted: \(report.id)")
        } catch {
            print("Failed to submit report: \(error)")
        }
    }
}
#endif
