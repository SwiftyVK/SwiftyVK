import Cocoa

final class ShareControllerMacOS: NSViewController, ShareController, NSTextFieldDelegate {
    @IBOutlet private weak var messageTextField: MultilineTextFieldMacOS?
    @IBOutlet private weak var doneButton: NSButton?
    @IBOutlet private weak var doneActivity: NSProgressIndicator?
    
    private var context: ShareContext = ShareContext()
    private var onPost: ((ShareContext) -> ())?

    var onDismiss: (() -> ())?
    
    override func viewDidLoad() {
        messageTextField?.delegate = self
        super.viewDidLoad()
        doneButton?.alphaValue = 0
        updateView()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        onDismiss?()
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
        self.context = context
        self.onPost = onPost
        
        updateView()
    }
    
    private func updateView() {
        DispatchQueue.anywayOnMain {
            messageTextField?.stringValue = context.message ?? ""
        }
        
        showPlaceholder(false)
        updateSendButton()
    }

    func showPlaceholder() {
        showPlaceholder(true)
    }
    
    private func showPlaceholder(_ enable: Bool) {
        enablePostButton(!enable)
        
//        DispatchQueue.anywayOnMain {
//            UIView.animate(withDuration: 0.3) {
//                self.placeholderView?.alpha = enable ? 1 : 0
//            }
//        }
    }
    
    func enablePostButton(_ enable: Bool) {
        DispatchQueue.anywayOnMain {
            if enable {
                doneButton?.animator().isEnabled = true
                doneButton?.animator().alphaValue = 1
                doneActivity?.animator().stopAnimation(nil)
            }
            else {
                doneButton?.animator().isEnabled = false
                doneButton?.animator().alphaValue = 0
                doneActivity?.animator().startAnimation(nil)
            }
        }
    }
    
    func showError(title: String, message: String, buttontext: String) {
        
    }
    
    func showWaitForConnection() {
        
    }
    
    func close() {
        DispatchQueue.anywayOnMain {
            messageTextField?.resignFirstResponder()
            self.dismiss(self)
        }
    }
    
    private func updateSendButton() {
        DispatchQueue.anywayOnMain {
            doneButton?.isEnabled = messageTextField?.stringValue.isEmpty == false || context.hasAttachments
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let strongSelf = self else { return }
            self?.onPost?(strongSelf.context)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(sender)
    }

    override func controlTextDidChange(_ notification: Notification) {
        guard let field = notification.object as? NSTextField else { return }
        context.message = field.stringValue
        updateSendButton()
    }
}
