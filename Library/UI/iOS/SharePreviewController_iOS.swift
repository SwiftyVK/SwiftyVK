import UIKit

final class SharePreviewControllerIOS: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var separatorHeight: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        messageTextView?.delegate = self
        separatorHeight?.constant = 1 / UIScreen.main.nativeScale
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
        }
        
        return true
    }
}
