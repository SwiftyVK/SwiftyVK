import UIKit

final class ShareControllerIOS: UIViewController, ShareController {
    
    @IBOutlet weak var roundedContainer: UIView?
    
    private weak var nextController: ShareController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        roundedContainer?.layer.cornerRadius = 15
        roundedContainer?.clipsToBounds = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextController = segue.destination as? ShareController {
            self.nextController = nextController
        }
    }
}
