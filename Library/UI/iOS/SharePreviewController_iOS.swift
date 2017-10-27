import UIKit

final class SharePreviewControllerIOS: UIViewController, UITextViewDelegate, ShareController {

    @IBOutlet weak var messageTextView: UITextView?
    @IBOutlet weak var separatorHeight: NSLayoutConstraint?
    
    private var context = ShareContext()
    private var completion: ((ShareContext) -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        messageTextView?.delegate = self
        separatorHeight?.constant = 1 / UIScreen.main.nativeScale
        
        messageTextView?.text = context.text
    }
    
    func share(_ context: ShareContext, completion: @escaping (ShareContext) -> ()) {
        self.context = context
        self.completion = completion
    }
    
    func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showError(title: String, message: String, buttontext: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttontext, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        context.text = textView.text
    }
    
    @IBAction func donePressed(_ sender: Any) {
        completion?(context)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
        }
        
        return true
    }
}
