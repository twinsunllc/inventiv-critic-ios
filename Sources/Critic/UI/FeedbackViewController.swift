#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

/// A UIKit view controller for collecting user feedback.
/// Wraps the SwiftUI FeedbackView using UIHostingController.
@available(iOS 16.0, *)
public final class FeedbackViewController: UIViewController {

    /// Called when a bug report is successfully submitted.
    public var onSubmit: ((BugReport) -> Void)?

    /// Called when the user cancels feedback.
    public var onCancel: (() -> Void)?

    /// Optional user identifier to attach to the report.
    public var userIdentifier: String?

    private var hostingController: UIHostingController<FeedbackView>?

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let feedbackView = FeedbackView(
            onSubmit: { [weak self] bugReport in
                self?.onSubmit?(bugReport)
                self?.dismiss(animated: true)
            },
            onCancel: { [weak self] in
                self?.onCancel?()
                self?.dismiss(animated: true)
            },
            userIdentifier: userIdentifier
        )

        let hosting = UIHostingController(rootView: feedbackView)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        hosting.didMove(toParent: self)
        hostingController = hosting
    }
}
#endif
