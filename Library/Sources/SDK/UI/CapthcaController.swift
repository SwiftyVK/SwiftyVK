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
  @IBOutlet fileprivate weak var imageView: NSImageView!
  @IBOutlet fileprivate weak var textField: NSTextField!
  fileprivate var parentWindow    : NSWindow?
  #endif
  #if os(iOS)
  @IBOutlet fileprivate weak var imageView: UIImageView!
  @IBOutlet fileprivate weak var textField: UITextField!
  fileprivate var parentView    : UIViewController?
  #endif
  private var imageUrl        : String?
  private var sid             : String?
  private var request         : Request?
  fileprivate let waitAnswer = DispatchSemaphore(value: 0)
  
  
  
  class func start(sid: String, imageUrl: String, request: Request) {
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
      request.asynchronous ? request.trySend() : request.tryInCurrentThread()
    }
    else {
      request.errorBlock(VK.Error(domain: "SwiftyVKDomain", code: 5, desc: "Captcha loading error", userInfo: nil, req: request))
    }
  }
  
  
  
  private func sendAndWait() -> Bool {
    let req = URLRequest(url: URL(string: self.imageUrl!)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
    var data: Data
    
    do {data = try NSURLConnection.sendSynchronousRequest(req, returning: nil)}
    catch _ {
      return false
    }
    
    DispatchQueue.main.sync(execute: {
      self.load(data)
    })
    
    _ = waitAnswer.wait(timeout: DispatchTime.distantFuture)
    return true
  }
  
  
  
  fileprivate func didLoad() {
    VK.Log.put("Global", "\(self) did load window")
    textField.delegate = self
    textField.becomeFirstResponder()
  }
  
  
  
  fileprivate func endEditing(_ text: String) {
    textField.delegate = nil
    sharedCaptchaAnswer = ["captcha_sid" : sid!, "captcha_key": text]
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
        NSNib(nibNamed:  CaptchaViewName, bundle: Resources.bundle)?.instantiate(withOwner: captcha, topLevelObjects: nil)
        captcha.windowDidLoad()
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
    
    
    override func windowDidLoad() {
      super.windowDidLoad()
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
