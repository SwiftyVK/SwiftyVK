import WebKit
#if os(OSX)
  import Cocoa
  let isMac = true
  class _WebControllerPrototype : NSWindowController, WebFrameLoadDelegate {}
#endif
#if os(iOS)
  import UIKit
  let isMac = false
  class _WebControllerPrototype : UIViewController, UIWebViewDelegate {}
#endif




internal let vkSheetQueue = dispatch_queue_create("com.VK.sheetQueue", DISPATCH_QUEUE_SERIAL)
private let autorizeUrl = "https://oauth.vk.com/authorize?"
private let WebViewName = Resources.withSuffix("WebView")
private weak var activeWebController : WebController?




//MARK: - BASE
class WebController : _WebControllerPrototype {
  #if os(OSX)
  @IBOutlet private weak var webView : WebView?
  @IBOutlet private weak var activity: NSProgressIndicator!
  private var parentWindow : NSWindow?
  #endif
  #if os(iOS)
  @IBOutlet private weak var webView : UIWebView?
  @IBOutlet private weak var activity : UIActivityIndicatorView!
  private var parentView : UIViewController?
  #endif
  private let waitUser = dispatch_semaphore_create(0)
  private var isExpand = false
  private var fails = 0
  private var urlRequest : NSURLRequest?
  private weak var request : Request?
  
  
  
  class func validate(request: Request, validationUrl: String) {
    dispatch_sync(vkSheetQueue, {
      self.start(url: validationUrl, request: request)
      request.isAsynchronous ? request.reSend() : request.sendInCurrentThread()
    })
  }
  
  
  
  internal class func start(url url: String, request: Request?) {
    let params          = getParamsForPlatform()
    let controller      = params.controller
    controller.request  = request
    controller.showWithUrl(url, isSheet: params.isSheet)
    Log([.views], "WebController wait user actions")
    activeWebController = controller
    dispatch_semaphore_wait(controller.waitUser, DISPATCH_TIME_FOREVER)
  }
  
  
  
  internal class func cancel() {
    activeWebController?.hide()
  }
  
  
  
  private func handleResponse(urlString : String) {
    if urlString.containsString("access_token=") {
      _ = Token(urlString: urlString)
      self.hide()
    }
    else if urlString.containsString("access_denied") {
      hide()
    }
    else if urlString.containsString("fail=1") {
      failValidation()
    }
    else if isMac && !isExpand && urlString.containsString(autorizeUrl) || urlString.containsString("act=security_check") {
      expand()
    }
    else {
      webView!.goBack()
    }
  }
  
  
  
  private func failValidation() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let err = VK.Error(domain: "VKSDKDomain", code: 3, desc: "Fail user validation", userInfo: nil, req: self.request)
      self.request?.errorBlock(error: err)
      VK.delegate.vkAutorizationFailed(err)
    }
    request?.attempts = request!.maxAttempts
    hide()
  }
  


  private func didFail(sender: AnyObject, didFailLoadWithError error: NSError?) {
    if fails <= 3 {
      fails++
      loadReq(self.urlRequest!)
    }
    else {
      fails = 0
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        VK.delegate.vkAutorizationFailed(VK.Error(ns: error!, req: nil))
      })
      hide()
    }
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
  extension WebController {
    
    
    
    private class func getParamsForPlatform() -> (controller: WebController, isSheet: Bool) {
      let params              = VK.delegate.vkWillPresentWindow()
      let controller          = WebController()
      
      dispatch_sync(dispatch_get_main_queue()) {
        NSNib(nibNamed: WebViewName, bundle: Resources.bundle)?.instantiateWithOwner(controller, topLevelObjects: nil)
        controller.windowDidLoad()
      }
      
      controller.parentWindow = (params.isSheet ? params.inWindow : nil)
      return (controller, params.isSheet)
      
    }
    
    
    
    override func windowDidLoad() {
      Log([.views], "\(self) INIT")
      webView!.frameLoadDelegate  = self
      
      if #available(OSX 10.10, *) {
        window?.styleMask |= NSFullSizeContentViewWindowMask
        window?.titleVisibility = .Hidden
        window?.titlebarAppearsTransparent = true
        window?.setFrame(
          NSRect(
            x: window!.frame.origin.x,
            y: window!.frame.origin.y,
            width: window!.frame.size.width,
            height: window!.frame.size.height - 20
          ), display: true
        )
      }
      
      super.windowDidLoad()
    }
    
    
    
    private func showWithUrl(url: String, isSheet: Bool) {
      dispatch_sync(dispatch_get_main_queue(), {
        isSheet
          ? self.parentWindow?.beginSheet(self.window!, completionHandler: nil)
          : self.showWindow(self)
        self.activity.startAnimation(self)
        self.urlRequest = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 3)
        self.webView!.setMaintainsBackForwardList(true)
        self.webView!.mainFrame.loadRequest(self.urlRequest!)
      })
    }
    
    
    
    private func expand() {
      NSThread.sleepForTimeInterval(1)
      isExpand = true
      NSApplication.sharedApplication().activateIgnoringOtherApps(true)
      let newHeight = CGFloat((self.webView!.stringByEvaluatingJavaScriptFromString("document.height") as NSString).floatValue)
      
      if let parent = parentWindow {
        self.window!.setFrame(NSMakeRect(
          (parent.frame.origin.x + ((parent.frame.width - 500) / 2)),
          parent.frame.origin.y + (parent.frame.height - (newHeight + 54) - 22),
          500,
          newHeight + 54),
          display: true, animate: true)
      }
      else {
        self.window!.setFrame(NSMakeRect(
          self.window!.frame.origin.x - self.window!.frame.size.width/2,
          self.window!.frame.origin.y - self.window!.frame.size.height,
          500,
          newHeight + 54),
          display: true, animate: true)
      }
    }
    
    
    
    private func loadReq(req: NSURLRequest) {
      self.webView!.mainFrame.loadRequest(self.urlRequest!)
    }
    
    
    
    private func hide() {
      if let parent = parentWindow {
        parent.endSheet(self.window!)
        self.window!.orderOut(parent)
      }
      self.webView!.frameLoadDelegate = nil
      dispatch_semaphore_signal(waitUser)
    }
    
    
    //MARK: frameLoadDelegate protocol
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
      handleResponse(frame.dataSource!.response.URL!.absoluteString)
    }
    
    
    
    func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
      didFail(sender, didFailLoadWithError: error)
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
  extension WebController {
    
    
    
    private class func getParamsForPlatform() -> (controller: WebController, isSheet: Bool) {
      let controller        = WebController(nibName: WebViewName, bundle: Resources.bundle)
      controller.parentView = VK.delegate.vkWillPresentView()
      return (controller, false)
    }
    
    
    
    override func viewDidLoad() {
      Log([.views], "\(self) INIT")
      webView!.delegate = self
      super.viewDidLoad()
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
      super.viewDidDisappear(animated)
      dispatch_semaphore_signal(waitUser)
    }
    
    
    
    private func showWithUrl(url: String, isSheet: Bool) {
      dispatch_sync(dispatch_get_main_queue(), {
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.parentView?.presentViewController(self, animated: true, completion: nil)
        self.webView?.layer.cornerRadius = 15
        self.webView?.layer.masksToBounds = true
        self.urlRequest = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 3)
        self.webView?.loadRequest(self.urlRequest!)
      })
    }
    
    
    
    private func loadReq(req: NSURLRequest) {
      webView!.loadRequest(self.urlRequest!)
    }
    
    
    
    private func expand() {}
    
    
    
    private func hide() {
      self.parentView?.dismissViewControllerAnimated(true, completion: nil)
      self.webView!.delegate = nil
    }
    
    
    
    //MARK: UIWebViewDelegate protocol
    func webViewDidFinishLoad(webView: UIWebView) {
      activity.stopAnimating()
      handleResponse(webView.request!.URL!.absoluteString)
    }
    
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
      self.didFail(webView, didFailLoadWithError: error)
    }
  }
#endif
