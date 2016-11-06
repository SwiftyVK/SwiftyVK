import Cocoa
import WebKit



private let WebViewName = Resources.withSuffix("WebView")



internal final class WebController: NSWindowController, WebFrameLoadDelegate {

    @IBOutlet private weak var webView: WebView?
    @IBOutlet private weak var activity: NSProgressIndicator!
    private var parentWindow: NSWindow?
    private weak var delegate: WebPresenter!
    private var url: String?



    class func create(withDelegate delegate: WebPresenter) -> WebController? {

        let controller          = WebController()
        controller.delegate     = delegate
        controller.parentWindow = VK.delegate?.vkWillPresentView()

        return DispatchQueue.main.sync {
            NSNib(nibNamed: WebViewName, bundle: Resources.bundle)?.instantiate(withOwner: controller, topLevelObjects: nil)

            _ = controller.parentWindow != nil
                ? controller.parentWindow?.beginSheet(controller.window!, completionHandler: nil)
                : controller.showWindow(nil)

            return controller
        }
    }



    override func awakeFromNib() {
        super.awakeFromNib()

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

        self.activity.startAnimation(self)
        self.webView!.setMaintainsBackForwardList(true)
    }



    func load(url: String) {

        if self.url == nil {
            self.url = url
        }

        VK.Log.put("WebController", "load \(self.url!)")

        DispatchQueue.main.async {
            self.webView!.mainFrame.load(URLRequest(url: URL(string: self.url!)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3))
        }
    }



    func expand() {
        VK.Log.put("WebController", "expand")

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

        window!.setFrame(NSRect(x: newX, y: newY, width: newWidth, height: newHeight), display: true, animate: true)
    }



    func goBack() {
        VK.Log.put("WebController", "goBack")

        DispatchQueue.main.async {
            self.webView?.goBack()
        }
    }



    func hide() {
        VK.Log.put("WebController", "hide")

        DispatchQueue.main.async {

            if let parent = self.parentWindow {
                parent.endSheet(self.window!)
                self.window!.orderOut(parent)
            }
            self.webView!.frameLoadDelegate = nil
            self.delegate?.finish()
        }
    }



    //MARK: - frameLoadDelegate protocol
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        delegate?.handleResponse(frame.dataSource!.response.url!.absoluteString)
    }



    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        delegate?.handleError(AuthError.failedAuthorization)
    }
}
