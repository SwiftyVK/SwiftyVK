import UIKit

final class ShareControllerIOS: UIViewController, ShareController {
    @IBOutlet private weak var roundedContainer: UIView?
    private weak var nextController: ShareController?
    var onDismiss: (() -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        roundedContainer?.layer.cornerRadius = 15
        roundedContainer?.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextController = segue.destination as? ShareController {
            self.nextController = nextController
        }
    }
    
    deinit {
        print("DEINIT", type(of: self))
    }
}
