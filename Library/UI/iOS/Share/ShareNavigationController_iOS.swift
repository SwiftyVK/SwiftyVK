import UIKit

final class ShareNavigationControllerIOS: UINavigationController, ShareController {
    
    private var nextController: ShareController? {
        return viewControllers.first as? ShareController
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> (), onDismiss: @escaping () -> ()) {
        nextController?.share(context, onPost: onPost, onDismiss: onDismiss)
    }
    
    func enablePostButton(_ enable: Bool) {
        nextController?.enablePostButton(enable)
    }
    
    func close() {
        nextController?.close()
    }
    
    func showError(title: String, message: String, buttontext: String) {
        nextController?.showError(title: title, message: message, buttontext: buttontext)
    }
}
