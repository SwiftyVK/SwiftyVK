#if os(OSX)
    import Cocoa
    class _СaptchaControllerPrototype : NSWindowController, NSTextFieldDelegate {}
#endif
#if os(iOS)
    import UIKit
    class _СaptchaControllerPrototype : UIViewController, UITextFieldDelegate {}
#endif



private let CaptchaViewName = Resources.withSuffix("CaptchaView")



//MARK: - BASE
internal final class СaptchaController: _СaptchaControllerPrototype {
    #if os(OSX)
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var textField: NSTextField!
    fileprivate var parentWindow    : NSWindow?
    #endif
    #if os(iOS)
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    fileprivate var parentView    : UIViewController?
    #endif
    private var imageUrl        : String?
    private var sid             : String?
    private var request         : RequestInstance?
    fileprivate let waitAnswer = DispatchSemaphore(value: 0)
    
    
    
    class func start(sid: String, imageUrl: String, request: RequestInstance) {
        var canContinue = false
        
        vkSheetQueue.sync {
            let captcha          = getCaptchaForPlatform()
            sharedCaptchaIsRun   = true
            captcha.sid          = sid
            captcha.imageUrl     = imageUrl
            captcha.request      = request
            canContinue          = captcha.sendAndWait()
            sharedCaptchaIsRun   = false
        }
        
        if canContinue {
            request.send()
        }
        else {
            request.handle(error: ErrorRequest.captchaFailed)
        }
    }
    
    
    
    private func sendAndWait() -> Bool {
        var data: Data
        
        do {
            let req = URLRequest(url: URL(string: self.imageUrl!)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
            data = try NSURLConnection.sendSynchronousRequest(req, returning: nil)}
        catch _ {
            return false
        }
        
        DispatchQueue.main.sync() {
            self.load(data)
        }
        
        _ = waitAnswer.wait(timeout: DispatchTime.distantFuture)
        return true
    }
    
    
    
    fileprivate func didLoad() {
        VK.Log.put("Global", "\(self) did load")
        textField.delegate = self
        textField.becomeFirstResponder()
        
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.sync {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TestCaptchaDidLoad"), object: self, userInfo: ["captcha": self])
            }
        }
    }
    
    
    
    fileprivate func endEditing(_ text: String) {
        sharedCaptchaAnswer = ["captcha_sid" : sid!, "captcha_key": text]
        textField.delegate = nil
    }
}
//
//
//
//
//
//
//
//
//
//
//MARK: - OSX
#if os(OSX)
    extension СaptchaController {
        
        
        
        fileprivate class func getCaptchaForPlatform() -> СaptchaController {
            let captcha          = СaptchaController()
            captcha.parentWindow = VK.delegate?.vkWillPresentView()
            
            DispatchQueue.main.sync {
                _ = NSNib(nibNamed: CaptchaViewName, bundle: Resources.bundle)?.instantiate(withOwner: captcha, topLevelObjects: nil)
            }
            
            return captcha
        }
        
        
        
        fileprivate func load(_ data: Data) {
            NSApplication.shared().activate(ignoringOtherApps: true)
            
            _ = parentWindow != nil
                ? self.parentWindow?.beginSheet(self.window!, completionHandler: nil)
                : self.showWindow(self)
            self.imageView.image = NSImage(data: data)
        }
        
        
        override func awakeFromNib() {
            super.awakeFromNib()
            didLoad()
            
            window?.styleMask.formUnion(NSFullSizeContentViewWindowMask)
            window?.titleVisibility = .hidden
            window?.titlebarAppearsTransparent = true
        }
        
        
        
        override func controlTextDidEndEditing(_ obj: Notification) {
            if window != nil {
                parentWindow?.endSheet(window!)
                window?.orderOut(parentWindow)
            }
            endEditing(textField.stringValue)
            waitAnswer.signal()
        }
    }
#endif
//
//
//
//
//
//
//
//
//
//
//MARK: - iOS
#if os(iOS)
    extension СaptchaController {
        
        
        
        fileprivate class func getCaptchaForPlatform() -> СaptchaController {
            let captcha          = СaptchaController(nibName:CaptchaViewName, bundle: Resources.bundle)
            captcha.parentView   = VK.delegate?.vkWillPresentView()
            return captcha
        }
        
        
        
        fileprivate func load(_ data: Data) {
            self.modalPresentationStyle = .overFullScreen
            self.modalTransitionStyle = .crossDissolve
            self.parentView?.present(self, animated: true, completion: nil)
            self.imageView?.layer.cornerRadius = 15
            self.imageView?.layer.masksToBounds = true
            self.imageView?.image = UIImage(data: data as Data)
        }
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            didLoad()
        }
        
        
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            waitAnswer.signal()
        }
        
        
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.parentView?.dismiss(animated: true, completion: nil)
            endEditing(textField.text!)
            return true
        }
    }
#endif
