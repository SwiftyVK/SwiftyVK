import UIKit

final class SharePreviewControllerIOS: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        messageTextView?.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
}
