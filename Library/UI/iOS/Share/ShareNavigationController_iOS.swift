import UIKit

final class ShareNavigationControllerIOS: UINavigationController, ShareController {
    
    var onDismiss: (() -> ())? {
        get { return nextController?.onDismiss }
        set { nextController?.onDismiss = newValue }
    }
    
    private var nextController: ShareController? {
        get { return viewControllers.first as? ShareController }
        set {}
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
        nextController?.share(context, onPost: onPost)
    }
    
    func showPlaceholder(_ enable: Bool) {
        nextController?.showPlaceholder(enable)
    }
    
    func showWaitForConnection() {
        nextController?.showWaitForConnection()
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
    
    deinit {
        print("DEINIT", type(of: self))
    }
}
