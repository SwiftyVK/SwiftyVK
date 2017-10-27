import UIKit

final class ShareNavigationControllerIOS: UINavigationController, ShareController {
    
    private var nextController: ShareController? {
        return viewControllers.first as? ShareController
    }
    
    func share(_ context: ShareContext, completion: @escaping (ShareContext) -> ()) {
        nextController?.share(context, completion: completion)
    }
    
    func close() {
        nextController?.close()
    }
    
    func showError(title: String, message: String, buttontext: String) {
        nextController?.showError(title: title, message: message, buttontext: buttontext)
    }
}
