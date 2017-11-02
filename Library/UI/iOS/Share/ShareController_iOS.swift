import UIKit

final class ShareControllerIOS: UIViewController, ShareController {
    
    @IBOutlet weak var roundedContainer: UIView?
    private weak var nextController: ShareController?
    private var onDismiss: (() -> ())?
    
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
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> (), onDismiss: @escaping () -> ()) {
        self.onDismiss = onDismiss
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextController = segue.destination as? ShareController {
            self.nextController = nextController
        }
    }
    
    deinit {
        print("DEINIT", type(of: self))
    }
}

