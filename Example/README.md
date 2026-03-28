# Critic SDK Example

A minimal SwiftUI app demonstrating the Critic iOS SDK.

## Running the Example

1. Open `Package.swift` in Xcode.
2. Set `apiToken` in `CriticExampleApp.swift` to your API token from the [Critic Web Portal](https://critic.inventiv.io/products).
3. Select an iOS Simulator and run.

### Local Development

To point at a local Critic server, edit `CriticExampleApp.swift`:

```swift
private static let customBaseURL: URL? = URL(string: "http://localhost:8000")
private static let apiToken = "your-api-token"
```

## Features Demonstrated

- SDK initialization with `Critic.shared.initialize()`
- Built-in feedback UI with `FeedbackView`
- Programmatic report submission with `Critic.shared.submitReport()`

## Integration Tests (headless, no Xcode)

The package also includes integration tests that exercise the full flow
(ping + submit bug report) directly against a running server, without
UIKit or a simulator:

```bash
CRITIC_BASE_URL=http://localhost:8000 \
CRITIC_API_TOKEN=your-api-token \
swift test --filter CriticIntegrationTests
```

These tests are disabled by default and only run when the environment
variables are set and a Critic server is reachable.
