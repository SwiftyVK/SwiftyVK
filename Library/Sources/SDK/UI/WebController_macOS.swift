import Cocoa
import WebKit

final class WebController_macOS: NSViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var preloader: NSProgressIndicator?
    
    private weak var handler: WebHandler?
    private var currentRequest: URLRequest?

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
        webView?.navigationDelegate = self
        preloader?.isDisplayedWhenStopped = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    func load(urlRequest: URLRequest, handler: WebHandler) {
        self.handler = handler
        self.currentRequest = urlRequest
        
        DispatchQueue.main.sync {
            preloader?.startAnimation(nil)
            loadCurrentRequest()
        }
    }
    
    func reload() {
        loadCurrentRequest()
    }
    
    private func loadCurrentRequest() {
        guard let currentRequest = currentRequest else {
            return
        }
        
        webView?.load(currentRequest)
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func dismiss() {
        DispatchQueue.main.sync {
            dismiss(nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        preloader?.stopAnimation(nil)
        handler?.handle(url: webView.url)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handler?.handle(error: error)
    }
}
