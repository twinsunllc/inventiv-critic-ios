# Changelog

All notable changes to the Critic iOS SDK are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-30

First stable release. The SDK has been completely rewritten with Swift 6 strict concurrency, async/await, the v3 API, and SwiftUI support.

### Added
- Swift 6 / async-await rewrite of the entire SDK using native `URLSession` with no external dependencies
- v3 API client for submitting bug reports and feedback
- SwiftUI-native feedback view
- Automatic console log capture via `OSLogStore` attached to bug reports
- Additional device metadata: extended memory details and network reachability status
- Swift Package Manager distribution via `Package.swift` (iOS 16+, macOS 13+)
- Nightly security CI workflow with 7-day package quarantine for CocoaPods dependencies
- GitHub Actions security audit workflow
- Comprehensive unit and integration test suite
- Example app demonstrating SDK integration

### Changed
- `App` model renamed to `CriticApp` to avoid collision with `SwiftUI.App`
- Log attachment filename standardized from `console.log` to `console-logs.txt`
- CI workflow renamed to "Nightly Security" for Scarif integration
- Network status implementation switched from `DispatchSemaphore` to `SCNetworkReachability`
- Deployment target raised to iOS 16.0; Swift version set to 6.0

### Removed
- All GET endpoints removed from the client SDK (submit-only interface)
- Legacy Objective-C artifacts and dead code from the original SDK

---

## [0.1.5] - 2024-01-01

### Changed
- Internal maintenance release; version bump only.

## [0.1.4] - 2023-12-01

### Added
- Support for `device_status` metadata attributes submitted alongside bug reports.

## [0.1.3] - 2023-11-01

### Added
- Support for `device_status` attributes in bug report submissions.

## [0.1.2] - 2023-10-01

### Changed
- Minor internal improvements.

## [0.1.1] - 2023-09-01

### Changed
- Updated to use v2 APIs for bug reporting.

## [0.0.7] - 2023-06-01

### Added
- Custom product metadata support in the default feedback screen and reporting flow.

## [0.0.6] - 2023-05-01

### Removed
- Eliminated an unused class.

## [0.0.5] - 2023-04-01

### Changed
- Updated default feedback screen title.

## [0.0.4] - 2023-03-01

### Changed
- Updated shake-detection alert style for the "No" (cancel) option.
- Added informative logging when `Critic.instance().startLogCapture()` is called.

## [0.0.3] - 2023-02-01

### Added
- Ability to customize default feedback screen and shake-detection dialog text via `Critic.instance()` configuration.
- Shake detection enabled by default as a trigger to prompt users to submit feedback.
- Convenience methods to disable log capture and shake detection.

## [0.0.2] - 2023-01-15

### Changed
- Simplified `reportCreator` by adding a default `init()`.

## [0.0.1] - 2023-01-01

### Added
- Initial release of the Critic iOS SDK.

[1.0.0]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.1.5...v1.0.0
[0.1.5]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.7...v0.1.1
[0.0.7]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/twinsunllc/inventiv-critic-ios/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/twinsunllc/inventiv-critic-ios/releases/tag/v0.0.1
