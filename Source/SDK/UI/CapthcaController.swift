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
internal class СaptchaController: _СaptchaControllerPrototype {
  #if os(OSX)
  @IBOutlet private weak var imageView: NSImageView!
  @IBOutlet private weak var textField: NSTextField!
  private var parentWindow    : NSWindow?
  #endif
  #if os(iOS)
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textField: UITextField!
  private var parentView    : UIViewController?
  #endif
  private var imageUrl        : String?
  private var sid             : String?
  private var request         : Request?
  private let waitAnswer = DispatchSemaphore(value: 0)
  
  
  
  class func start(sid: String, imageUrl: String, request: Request) {
    var canContinue = false
    
    vkSheetQueue.sync {
      let captcha          = getCapthcaForPlatform()
      sharedCaptchaIsRun   = true
      captcha.sid          = sid
      captcha.imageUrl     = imageUrl
      captcha.request      = request
      canContinue          = captcha.sendAndWait()
      sharedCaptchaIsRun   = false
    }
    
    if canContinue {
      request.isAsynchronous ? request.trySend() : request.tryInCurrentThread()
    }
    else {
      request.errorBlock(error: VK.Error(domain: "VKSDKDomain", code: 5, desc: "Capthca loading error", userInfo: nil, req: request))
    }
  }
  
  
  
  private func sendAndWait() -> Bool {
    let req = URLRequest(url: URL(string: self.imageUrl!)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
    var data: Data?
    
    do {data = try NSURLConnection.sendSynchronousRequest(req, returning: nil)}
    catch _ {
      return false
    }
    
    DispatchQueue.main.sync(execute: {
      self.load(data!)
    })
    
    #if os(iOS)
      //NSThread.sleepForTimeInterval(0.5)
    #endif
    
    _ = waitAnswer.wait(timeout: DispatchTime.distantFuture)
    return true
  }
  
  
  
  private func didLoad() {
    VK.Log.put("Global", "\(self) did load window")
    textField.delegate = self
    textField.becomeFirstResponder()
  }
  
  
  
  private func endEditing(_ text: String) {
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
    
    
    
    private class func getCapthcaForPlatform() -> СaptchaController {
      let params           = VK.delegate.vkWillPresentWindow()
      let captcha          = СaptchaController()
      
      DispatchQueue.main.sync {
        NSNib(nibNamed:  CaptchaViewName, bundle: Resources.bundle)?.instantiate(withOwner: captcha, topLevelObjects: nil)
        captcha.windowDidLoad()
      }
      
      captcha.parentWindow = (params.isSheet ? params.inWindow : nil)
      return captcha
    }
    
    
    
    private func load(_ data: Data) {
      NSApplication.shared().activateIgnoringOtherApps(true)
      
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
    
    
    
    private class func getCapthcaForPlatform() -> СaptchaController {
      let captcha          = СaptchaController(nibName:CaptchaViewName, bundle: Resources.bundle)
      captcha.parentView   = VK.delegate?.vkWillPresentView()
      return captcha
    }
    
    
    
    private func load(_ data: NSData) {
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
