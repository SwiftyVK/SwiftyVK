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




internal let vkSheetQueue = DispatchQueue(label: "com.VK.sheetQueue")
private let authorizeUrl = "https://oauth.vk.com/authorize?"
private let WebViewName = Resources.withSuffix("WebView")
private weak var activeWebController : WebController?




//MARK: - BASE
internal final class WebController : _WebControllerPrototype {
  #if os(OSX)
  @IBOutlet fileprivate weak var webView : WebView?
  @IBOutlet fileprivate weak var activity: NSProgressIndicator!
  fileprivate var parentWindow : NSWindow?
  #endif
  #if os(iOS)
  @IBOutlet fileprivate weak var webView : UIWebView?
  @IBOutlet fileprivate weak var activity : UIActivityIndicatorView!
  fileprivate var parentView : UIViewController?
  #endif
  fileprivate let waitUser = DispatchSemaphore(value: 0)
  private var fails = 0
  fileprivate var urlRequest : URLRequest?
  private weak var request : Request?
  private var isValidation = false
  
  
  class func validate(_ request: Request, validationUrl: String) {
    
    vkSheetQueue.sync(execute: {
      self.start(url: validationUrl, request: request, isValidation: true)
      request.asynchronous ? request.trySend() : request.tryInCurrentThread()
    })
  }
  
  
  
  internal class func start(url: String, request: Request?, isValidation : Bool = false) {
    let params              = getParamsForPlatform()
    let controller          = params.controller
    controller.request      = request
    controller.showWithUrl(url, isSheet: params.isSheet)
    activeWebController     = controller
    controller.isValidation = isValidation
    VK.Log.put("Global", "WebController wait user actions")
    _ = controller.waitUser.wait(timeout: DispatchTime.distantFuture)
  }
  
  
  
  internal class func cancel() {
    activeWebController?.hide()
  }
  
  
  
  fileprivate func handleResponse(_ urlString : String) {
    if urlString.contains("access_token=") {
      _ = Token(urlString: urlString)
      self.hide()
    }
    else if urlString.contains("access_denied") {
      hide()
    }
    else if urlString.contains("fail=1") {
      failValidation()
    }
    else if urlString.contains(authorizeUrl) || urlString.contains("act=security_check") || urlString.contains("https://m.vk.com/login?") {
      expand()
    }
    else {
      webView!.goBack()
    }
  }
  
  
  
  private func failValidation() {
    DispatchQueue.global(qos: .default).async {
      let err = VKError(code: 3, desc: "Fail user validation", request: self.request)
      self.request?.errorBlock(err)
      VK.delegate?.vkAutorizationFailedWith(error: err)
    }
    request?.attempts = request!.maxAttempts
    hide()
  }
  
  
  
  fileprivate func didFail(_ sender: AnyObject, didFailLoadWithError error: NSError?) {
    if fails <= 3 {
      fails += 1
      loadReq()
    }
    else {
      fails = 0
      isValidation ? failValidation() : ()
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
    
    
    
    fileprivate class func getParamsForPlatform() -> (controller: WebController, isSheet: Bool) {
      let controller          = WebController()
        controller.parentWindow = VK.delegate?.vkWillPresentView()

      
      DispatchQueue.main.sync {
        NSNib(nibNamed: WebViewName, bundle: Resources.bundle)?.instantiate(withOwner: controller, topLevelObjects: nil)
        controller.windowDidLoad()
      }
      
      return (controller, controller.parentWindow != nil)
      
    }
    
    
    
    override func windowDidLoad() {
      VK.Log.put("Global", "\(self) INIT")
      webView!.frameLoadDelegate  = self
      
        window?.styleMask.formUnion(NSFullSizeContentViewWindowMask)
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        window?.setFrame(
          NSRect(
            x: window!.frame.origin.x,
            y: window!.frame.origin.y,
            width: window!.frame.size.width,
            height: window!.frame.size.height - 20
          ), display: true
        )
      
      super.windowDidLoad()
    }
    
    
    
    fileprivate func showWithUrl(_ url: String, isSheet: Bool) {
      DispatchQueue.main.sync(execute: {
        _ = isSheet
          ? self.parentWindow?.beginSheet(self.window!, completionHandler: nil)
          : self.showWindow(self)
        self.activity.startAnimation(self)
        self.urlRequest = URLRequest(url: URL(string: url)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 3)
        self.webView!.setMaintainsBackForwardList(true)
        self.webView!.mainFrame.load(self.urlRequest!)
      })
    }
    
    
    
    fileprivate func expand() {
      NSApplication.shared().activate(ignoringOtherApps: true)
      let newHeight = min(
        CGFloat((webView!.stringByEvaluatingJavaScript(from: "document.height") as NSString).floatValue),
        450
      )
      
      if let parent = parentWindow {
        window!.setFrame(NSMakeRect(
          (parent.frame.origin.x + ((parent.frame.width - 500) / 2)),
          parent.frame.origin.y + (parent.frame.height - (newHeight + 54) - 22),
          500,
          newHeight + 54),
          display: true, animate: true)
      }
      else {
        window!.setFrame(NSMakeRect(
          window!.frame.origin.x - window!.frame.size.width/2,
          window!.frame.origin.y - window!.frame.size.height,
          500,
          newHeight + 54),
          display: true, animate: true)
      }
    }
    
    
    
    fileprivate func loadReq() {
      self.webView!.mainFrame.load(self.urlRequest!)
    }
    
    
    
    fileprivate func hide() {
      if let parent = parentWindow {
        parent.endSheet(self.window!)
        self.window!.orderOut(parent)
      }
      self.webView!.frameLoadDelegate = nil
      waitUser.signal()
    }
    
    
    //MARK: frameLoadDelegate protocol
    func webView(_ sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
      handleResponse(frame.dataSource!.response.url!.absoluteString)
    }
    
    
    
    func webView(_ sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
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
    
    
    
    fileprivate class func getParamsForPlatform() -> (controller: WebController, isSheet: Bool) {
      let controller        = WebController(nibName: WebViewName, bundle: Resources.bundle)
      controller.parentView = VK.delegate?.vkWillPresentView()
      return (controller, false)
    }
    
    
    
    override func viewDidLoad() {
      VK.Log.put("Global", "\(self) INIT")
      webView!.delegate = self
      super.viewDidLoad()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      waitUser.signal()
    }
    
    
    
    fileprivate func showWithUrl(_ url: String, isSheet: Bool) {
      DispatchQueue.main.sync() {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.parentView?.present(self, animated: true, completion: nil)
        self.webView?.layer.cornerRadius = 15
        self.webView?.layer.masksToBounds = true
        self.urlRequest = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3)
        self.webView?.loadRequest(self.urlRequest!)
      }
    }
    
    
    
    fileprivate func loadReq() {
      webView!.loadRequest(self.urlRequest!)
    }
    
    
    
    fileprivate func expand() {}
    
    
    
    fileprivate func hide() {
      self.parentView?.dismiss(animated: true, completion: nil)
      self.webView!.delegate = nil
    }
    
    
    
    //MARK: UIWebViewDelegate protocol
    func webViewDidFinishLoad(_ webView: UIWebView) {
      activity.stopAnimating()
      handleResponse(webView.request!.url!.absoluteString)
    }
    
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?) {
      self.didFail(webView, didFailLoadWithError: error)
    }
  }
#endif
