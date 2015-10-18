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
  private let waitAnswer = dispatch_semaphore_create(0)
  
  
  
  class func start(sid sid: String, imageUrl: String, request: Request) {
    dispatch_sync(vkSheetQueue, {
      let captcha          = getCapthcaForPlatform()
      sharedCaptchaIsRun   = true
      captcha.sid          = sid
      captcha.imageUrl     = imageUrl.stringByReplacingOccurrencesOfString("http://", withString: "https://")
      captcha.request      = request
      let isContinue       = captcha.sendAndWait()
      sharedCaptchaIsRun   = false
      
      isContinue
        ? request.isAsynchronous ? request.reSend() : request.sendInCurrentThread()
        : false
    })
  }
  
  
  
  private func sendAndWait() -> Bool {
    let req = NSURLRequest(URL: NSURL(string: self.imageUrl!)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
    var data: NSData?
    
    do {data = try NSURLConnection.sendSynchronousRequest(req, returningResponse: nil)}
    catch let error as NSError {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {VK.Error(ns: error, req: nil).finaly()})
      return false
    }
    
    dispatch_sync(dispatch_get_main_queue(), {
      self.load(data!)
    })
    
    #if os(iOS)
      //NSThread.sleepForTimeInterval(0.5)
    #endif
  
    dispatch_semaphore_wait(waitAnswer, DISPATCH_TIME_FOREVER)
    return true
  }
  
  
  
  private func didLoad() {
    Log([.views], "\(self) did load window")
    textField.delegate = self
    textField.becomeFirstResponder()
  }
  
  
  
  private func endEditing(text: String) {
    textField.delegate = nil
    sharedCatchaAnswer = ["captcha_sid" : sid!, "captcha_key": text]
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
      
      dispatch_sync(dispatch_get_main_queue()) {
        NSNib(nibNamed:  CaptchaViewName, bundle: Resources.bundle)?.instantiateWithOwner(captcha, topLevelObjects: nil)
        captcha.windowDidLoad()
      }
      
      captcha.parentWindow = (params.isSheet ? params.inWindow : nil)
      return captcha
    }
    
    
    
    private func load(data: NSData) {
      NSApplication.sharedApplication().activateIgnoringOtherApps(true)
      
      parentWindow != nil
        ? self.parentWindow?.beginSheet(self.window!, completionHandler: nil)
        : self.showWindow(self)
      self.imageView.image = NSImage(data: data)
    }
    
    
    override func windowDidLoad() {
      super.windowDidLoad()
      didLoad()
      
      if #available(OSX 10.10, *) {
        window?.styleMask |= NSFullSizeContentViewWindowMask
        window?.titleVisibility = .Hidden
        window?.titlebarAppearsTransparent = true
      }
    }
    
    
    
    override func controlTextDidEndEditing(obj: NSNotification) {
      if window != nil {
        parentWindow?.endSheet(window!)
        window?.orderOut(parentWindow)
      }
      endEditing(textField.stringValue)
      dispatch_semaphore_signal(waitAnswer)
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
      captcha.parentView   = VK.delegate.vkWillPresentView()
      return captcha
    }
    
    
    
    private func load(data: NSData) {
      self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
      self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
      self.parentView?.presentViewController(self, animated: true, completion: nil)
      self.imageView?.layer.cornerRadius = 5
      self.imageView?.layer.masksToBounds = true
      self.imageView?.image = UIImage(data: data)
    }
    
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      didLoad()
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
      dispatch_semaphore_signal(waitAnswer)
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
      self.parentView?.dismissViewControllerAnimated(true, completion: nil)
      endEditing(textField.text!)
      return true
    }
  }
#endif
