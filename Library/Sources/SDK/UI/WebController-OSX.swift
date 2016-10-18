import Cocoa
import WebKit



internal final class WebController_OSX: NSWindowController, WebFrameLoadDelegate {
    
    @IBOutlet fileprivate weak var webView : WebView?
    @IBOutlet fileprivate weak var activity: NSProgressIndicator!
    fileprivate var parentWindow: NSWindow?
    fileprivate weak var delegate: WebProxy!
    
    
//    fileprivate class func getParamsForPlatform() -> (controller: WebController, isSheet: Bool) {
//        let controller          = WebController()
//        controller.parentWindow = VK.delegate?.vkWillPresentView()
//        
//        
//        DispatchQueue.main.sync {
//            NSNib(nibNamed: WebViewName, bundle: Resources.bundle)?.instantiate(withOwner: controller, topLevelObjects: nil)
//            controller.windowDidLoad()
//        }
//        
//        return (controller, controller.parentWindow != nil)
//        
//    }
    
    
    
    override func windowDidLoad() {
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
        let newHeight = CGFloat(350)
        let newWidth = CGFloat(500)
        let newX: CGFloat
        let newY: CGFloat
        
        if let parent = parentWindow {
            newX = (parent.frame.origin.x + ((parent.frame.width - newWidth) / 2))
            newY = parent.frame.origin.y + (parent.frame.height - newHeight)
        }
        else {
            newX = window!.frame.origin.x - window!.frame.size.width/2
            newY = window!.frame.origin.y - window!.frame.size.height
        }
        
        window!.setFrame(NSMakeRect(newX, newY, newWidth, newHeight), display: true, animate: true)
    }
    
    
    
    fileprivate func load(request: URLRequest) {
        self.webView!.mainFrame.load(request)
    }
    
    
    
    fileprivate func hide() {
        if let parent = parentWindow {
            parent.endSheet(self.window!)
            self.window!.orderOut(parent)
        }
        self.webView!.frameLoadDelegate = nil
    }
    
    
    
    //MARK: frameLoadDelegate protocol
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
//        handleResponse(frame.dataSource!.response.url!.absoluteString)
    }
    
    
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
//        didFail(sender, didFailLoadWithError: error)
    }
}
