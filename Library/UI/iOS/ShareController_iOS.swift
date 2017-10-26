import UIKit

final class ShareControllerIOS: UIViewController, ShareController {
    
    @IBOutlet weak var roundedContainer: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        roundedContainer?.layer.cornerRadius = 15
        roundedContainer?.clipsToBounds = true
    }
    
    func share(_ context: ShareContext) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
