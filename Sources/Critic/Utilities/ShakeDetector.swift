#if canImport(UIKit)
import UIKit

/// A UIWindow subclass that detects shake gestures to trigger feedback collection.
@available(iOS 16.0, *)
@MainActor
public final class ShakeDetectingWindow: UIWindow {

    /// Called when a shake gesture is detected.
    public var onShake: (() -> Void)?

    public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            onShake?()
        }
    }
}

/// Manages shake detection and feedback presentation.
@available(iOS 16.0, *)
@MainActor
public final class ShakeDetector {

    private weak var window: ShakeDetectingWindow?

    /// Creates a new shake detector.
    public init() {}

    /// Installs the shake detector on the given window.
    /// When a shake is detected, the FeedbackViewController is presented.
    public func install(on window: ShakeDetectingWindow) {
        self.window = window
        window.onShake = { [weak self] in
            self?.presentFeedback()
        }
    }

    /// Presents the feedback view controller.
    public func presentFeedback() {
        guard let rootVC = window?.rootViewController else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // Don't present if already showing feedback
        if topVC is FeedbackViewController { return }

        let feedbackVC = FeedbackViewController()
        feedbackVC.modalPresentationStyle = .formSheet
        feedbackVC.onCancel = {
            topVC.dismiss(animated: true)
        }
        feedbackVC.onSubmit = { _ in
            topVC.dismiss(animated: true)
        }
        topVC.present(feedbackVC, animated: true)
    }
}
#endif
