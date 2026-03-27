#if canImport(UIKit)
import UIKit

/// A UIKit view controller for collecting user feedback.
@available(iOS 16.0, *)
public final class FeedbackViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
#endif
