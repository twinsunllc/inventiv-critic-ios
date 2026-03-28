# Critic SDK Example

A minimal SwiftUI app demonstrating the Critic iOS SDK.

## Running the Example

1. Open `Package.swift` in Xcode.
2. Replace `"YOUR_API_TOKEN"` in `CriticExampleApp.swift` with your API token from the [Critic Web Portal](https://critic.inventiv.io/products).
3. Select an iOS Simulator and run.

## Features Demonstrated

- SDK initialization with `Critic.shared.initialize()`
- Built-in feedback UI with `FeedbackView`
- Programmatic report submission with `Critic.shared.submitReport()`
