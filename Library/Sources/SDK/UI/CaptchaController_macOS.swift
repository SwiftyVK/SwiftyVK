import Cocoa

final class CaptchaController_macOS: NSViewController, NSTextFieldDelegate, CaptchaController {
    
    @IBOutlet private weak var imageView: NSImageView?
    @IBOutlet private weak var textField: NSTextField?
    private var onFinish: ((String) -> ())?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        textField?.delegate = self
    }
    
    func present(imageData: Data, onFinish: @escaping (String) -> ()) {
        DispatchQueue.main.sync {
            self.imageView?.image = NSImage(data: imageData)
            textField?.stringValue = ""
        }
        self.onFinish = onFinish
    }
    
    func dismiss() {
        DispatchQueue.main.sync {
            dismiss(nil)
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let result = textField?.stringValue, !result.isEmpty else {
            return
        }
        
        onFinish?(result)
    }
}
