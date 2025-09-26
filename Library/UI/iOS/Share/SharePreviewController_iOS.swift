#if os(iOS)
import UIKit

final class SharePreviewControllerIOS: UIViewController, UITextViewDelegate, ShareController {

    @IBOutlet private weak var messageTextView: UITextView?
    @IBOutlet private weak var linkTitle: UILabel?
    @IBOutlet private weak var linkUrl: UILabel?
    @IBOutlet private weak var imageCollection: ShareImageCollectionViewIOS?
    @IBOutlet private var sendButton: UIBarButtonItem?
    @IBOutlet private weak var placeholderView: UIView?
    @IBOutlet private weak var placeholderIndicator: UIActivityIndicatorView?
    @IBOutlet private weak var noConnectionLabel: UILabel?
    
    @IBOutlet private weak var linkViewHeight: NSLayoutConstraint?
    @IBOutlet private weak var imageCollectionHeight: NSLayoutConstraint?
    
    private var context = ShareContext()
    private var onPost: ((ShareContext) -> ())?
    private var rightButton: UIBarButtonItem?
    var onDismiss: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageCollectionHeight?.constant = context.images.isEmpty ? 0 : 135
        linkViewHeight?.constant = context.link != nil ? 51 : 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let preferencesController = segue.destination as? SharePreferencesControllerIOS {
            preferencesController.set(preferences: context.preferences)
        }
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
        self.context = context
        self.onPost = onPost
        
        DispatchQueue.anywayOnMain {
            updateView()
        }
    }
    
    private func updateView() {
        imageCollection?.set(images: context.images)
        
        messageTextView?.text = context.message
        
        linkTitle?.text = context.link?.title
        linkUrl?.text = context.link?.url.absoluteString
        
        showPlaceholder(false)
        updateSendButton()
    }
    
    func showPlaceholder() {
        showPlaceholder(true)
    }
    
    private func showPlaceholder(_ enable: Bool) {
        enablePostButton(!enable)
        
        DispatchQueue.anywayOnMain {
            UIView.animate(withDuration: 0.3) {
                self.placeholderView?.alpha = enable ? 1 : 0
            }
        }
    }
    
    func showWaitForConnection() {
        DispatchQueue.anywayOnMain {
            UIView.animate(withDuration: 0.3) {
                self.noConnectionLabel?.alpha = 1
            }
        }
    }
    
    func enablePostButton(_ enable: Bool) {
        DispatchQueue.anywayOnMain {
            if enable {
                navigationItem.setRightBarButton(sendButton, animated: true)
            }
            else {
                let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                let barButton = UIBarButtonItem(customView: activityIndicator)
                navigationItem.setRightBarButton(barButton, animated: true)
                activityIndicator.startAnimating()
            }
        }
    }
    
    func close() {
        DispatchQueue.anywayOnMain {
            messageTextView?.endEditing(true)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showError(title: String, message: String, buttontext: String) {
        DispatchQueue.anywayOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttontext, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        context.message = textView.text
        updateSendButton()
    }
    
    private func updateSendButton() {
        sendButton?.isEnabled = messageTextView?.text.isEmpty == false || context.hasAttachments
    }
    
    @IBAction func donePressed(_ sender: Any) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else { return }
            self?.onPost?(strongSelf.context)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        close()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
        }
        
        return true
    }
}

#endif
