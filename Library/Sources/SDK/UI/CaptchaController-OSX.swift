#if os(macOS)
    import Cocoa
    
    private let captchaViewName = Resources.withSuffix("CaptchaView")
    
    class CaptchaController: NSWindowController, NSTextFieldDelegate {
        
        @IBOutlet private weak var imageView: NSImageView!
        @IBOutlet private weak var textField: NSTextField!
        private var parentWindow: NSWindow?
        private weak var delegate: CaptchaPresenter!
        private var image: NSImage?
        
        static func create(data: Data, delegate: CaptchaPresenter) -> CaptchaController? {
            
            guard let image = NSImage(data: data) else {
                return nil
            }
            
            let controller = CaptchaController()
            controller.parentWindow = VK.legacyDelegate?.vkWillPresentView()
            controller.image = image
            controller.delegate = delegate
            
            return DispatchQueue.main.sync {
                NSNib(nibNamed: captchaViewName, bundle: Resources.bundle)?.instantiate(withOwner: controller, topLevelObjects: nil)
                
                guard let window = controller.window else {
                    return nil
                }
                
                _ = controller.parentWindow != nil
                    ? controller.parentWindow?.beginSheet(window, completionHandler: nil)
                    : controller.showWindow(nil)
                
                return controller
            }
        }
        
        func setText(to text: String) {
            textField.stringValue = text
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            window?.styleMask.formUnion(NSFullSizeContentViewWindowMask)
            window?.titleVisibility = .hidden
            window?.titlebarAppearsTransparent = true
            imageView.image = image
            textField.delegate = self
            
            DispatchQueue.global(qos: .background).async {
                Thread.sleep(forTimeInterval: 0.5)
                self.delegate.didAppear()
            }
        }
        
        override func controlTextDidEndEditing(_ obj: Notification) {
            if let window = window {
                parentWindow?.endSheet(window)
                window.orderOut(parentWindow)
            }
            delegate.finish(answer: textField.stringValue)
        }
        
    }
#endif
