# Inventiv Critic iOS SDK

[![CI](https://github.com/twinsunllc/inventiv-critic-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/twinsunllc/inventiv-critic-ios/actions/workflows/ci.yml)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+-blue.svg)](https://developer.apple.com/ios/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A Swift SDK for collecting actionable customer feedback via [Inventiv Critic](https://inventiv.io/critic/). Built with modern Swift concurrency (async/await), strict Sendable conformance, and zero external dependencies.

## Installation

### Swift Package Manager (Recommended)

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/twinsunllc/inventiv-critic-ios.git", from: "1.0.0")
]
```

Then add `"Critic"` to the target's dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Critic", package: "inventiv-critic-ios")
    ]
)
```

Or in Xcode: **File > Add Package Dependencies...** and enter:

```
https://github.com/twinsunllc/inventiv-critic-ios
```

### CocoaPods

Add `Critic` to your `Podfile`:

```ruby
pod 'Critic', '~> 1.0'
```

Then run:

```bash
bundle exec pod install
```

## Quick Start

### 1. Initialize the SDK

Call `initialize` early in your app lifecycle — typically in your `AppDelegate` or `App` struct:

```swift
import Critic

@main
struct MyApp: App {
    init() {
        Task {
            try await Critic.shared.initialize(apiToken: "YOUR_API_TOKEN")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Or in a UIKit `AppDelegate`:

```swift
import Critic

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Task {
            try await Critic.shared.initialize(apiToken: "YOUR_API_TOKEN")
        }
        return true
    }
}
```

Find your API token in the [Critic Web Portal](https://critic.inventiv.io/products) under your product's details.

### 2. Submit Feedback

Submit a bug report programmatically:

```swift
let input = BugReportInput(
    description: "App crashes when tapping the profile button",
    metadata: ["screen": "profile", "user_tier": "premium"],
    stepsToReproduce: "1. Open app\n2. Tap Profile\n3. App crashes",
    userIdentifier: "user@example.com"
)

do {
    let report = try await Critic.shared.submitReport(input)
    print("Report submitted: \(report.id)")
} catch {
    print("Failed to submit: \(error)")
}
```

### 3. Submit with Attachments

Include screenshots or log files with your report:

```swift
let screenshotData = try Data(contentsOf: screenshotURL)

let report = try await Critic.shared.submitReport(
    BugReportInput(description: "UI layout broken on iPad"),
    attachments: [
        (filename: "screenshot.png", mimeType: "image/png", data: screenshotData)
    ]
)
```

## Built-in UI

### SwiftUI Feedback View

Present the built-in feedback form in SwiftUI:

```swift
import Critic

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView(
                onSubmit: { report in
                    showFeedback = false
                    print("Submitted: \(report.id)")
                },
                onCancel: {
                    showFeedback = false
                },
                userIdentifier: "user@example.com"
            )
        }
    }
}
```

### UIKit Feedback View Controller

Use `FeedbackViewController` in UIKit apps:

```swift
import Critic

let feedbackVC = FeedbackViewController()
feedbackVC.userIdentifier = "user@example.com"
feedbackVC.onSubmit = { report in
    print("Submitted: \(report.id)")
}
feedbackVC.onCancel = {
    print("Cancelled")
}
feedbackVC.modalPresentationStyle = .formSheet
present(feedbackVC, animated: true)
```

### Shake to Send Feedback

Enable shake-to-report using `ShakeDetectingWindow`:

```swift
import Critic

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let shakeDetector = ShakeDetector()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = ShakeDetectingWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: YourRootVC())
        self.window = window
        window.makeKeyAndVisible()

        shakeDetector.install(on: window)
    }
}
```

## API Client

For advanced use cases, access the API client directly after initialization:

```swift
guard let api = Critic.shared.api else { return }

// List bug reports
let reports = try await api.listBugReports(appApiToken: "YOUR_APP_TOKEN")
for report in reports.items {
    print("\(report.id): \(report.description ?? "No description")")
}

// Get a single bug report
let report = try await api.getBugReport(id: "report-uuid", appApiToken: "YOUR_APP_TOKEN")

// List devices
let devices = try await api.listDevices(appApiToken: "YOUR_APP_TOKEN")
```

## Error Handling

All API methods throw `CriticError` on failure:

```swift
do {
    let report = try await Critic.shared.submitReport(input)
} catch CriticError.unauthorized {
    print("Invalid API token")
} catch CriticError.forbidden {
    print("Access forbidden")
} catch CriticError.notFound {
    print("Resource not found")
} catch CriticError.validationFailed(let message) {
    print("Validation error: \(message)")
} catch CriticError.badRequest(let message) {
    print("Bad request: \(message)")
} catch CriticError.notInitialized {
    print("SDK not initialized — call Critic.shared.initialize() first")
} catch CriticError.networkError(let message) {
    print("Network error: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Custom Base URL

Point the SDK to a self-hosted Critic instance:

```swift
try await Critic.shared.initialize(
    apiToken: "YOUR_API_TOKEN",
    baseURL: URL(string: "https://your-critic-instance.example.com")
)
```

## Requirements

- iOS 16.0+
- Swift 6.0+
- Xcode 16.0+

## Contributing

1. Clone this repository.
2. Open `Package.swift` in Xcode.
3. Run tests with `Cmd+U` or `swift test`.

## License

This library is released under the [MIT License](LICENSE).
