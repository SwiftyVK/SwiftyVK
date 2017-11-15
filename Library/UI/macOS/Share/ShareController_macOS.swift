import Cocoa

final class ShareControllerMacOS: NSViewController, ShareController, NSTextFieldDelegate {
    @IBOutlet private weak var messageTextField: MultilineTextFieldMacOS?
    @IBOutlet private weak var doneButton: NSButton?
    @IBOutlet private weak var doneActivity: NSProgressIndicator?
    @IBOutlet private weak var buttonsView: NSView?
    @IBOutlet private weak var linkTitleLabel: NSTextField?
    @IBOutlet private weak var linkAdressLabel: NSTextField?
    
    private var context: ShareContext = ShareContext()
    private var onPost: ((ShareContext) -> ())?

    var onDismiss: (() -> ())?
    
    override func viewDidLoad() {
        messageTextField?.delegate = self
        super.viewDidLoad()
        doneButton?.alphaValue = 0
        updateView()
        buttonsView?.wantsLayer = true
        buttonsView?.layer?.backgroundColor = NSColor(
            calibratedRed: 0.314,
            green: 0.448,
            blue: 0.6,
            alpha: 1
            ).cgColor
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        onDismiss?()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let preferencesController = segue.destinationController as? SharePreferencesControllerMacOS {
            preferencesController.set(preferences: context.preferences)
        }
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
        self.context = context
        self.onPost = onPost
        
        updateView()
    }
    
    private func updateView() {
        DispatchQueue.anywayOnMain {
            messageTextField?.stringValue = context.message ?? ""
            messageTextField?.window?.makeFirstResponder(nil)
            linkTitleLabel?.stringValue = context.link?.title ?? ""
            linkAdressLabel?.stringValue = context.link?.url.absoluteString ?? ""

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
