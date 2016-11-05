import Cocoa



private let CaptchaViewName = Resources.withSuffix("CaptchaView")



class CaptchaController: NSWindowController, NSTextFieldDelegate {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var textField: NSTextField!
    private var parentWindow: NSWindow?
    private weak var delegate: CaptchaPresenter!
    private var image: NSImage?
    
    
    static func create(data: Data, delegate: CaptchaPresenter) -> CaptchaController? {
        
        guard let image = NSImage(data: data) else {
            return nil
        }
        
        let controller = CaptchaController()
        controller.parentWindow = VK.delegate?.vkWillPresentView()
        controller.image = image
        controller.delegate = delegate
        
        DispatchQueue.main.sync {
            NSNib(nibNamed: CaptchaViewName, bundle: Resources.bundle)?.instantiate(withOwner: controller, topLevelObjects: nil)
            
            _ = controller.parentWindow != nil
                ? controller.parentWindow?.beginSheet(controller.window!, completionHandler: nil)
                : controller.showWindow(nil)
        }
        
        return controller
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
        if window != nil {
            parentWindow?.endSheet(window!)
            window?.orderOut(parentWindow)
        }
        delegate.finish(answer: textField.stringValue)
    }
    
}
