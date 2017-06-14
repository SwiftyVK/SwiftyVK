import Cocoa
import WebKit

final class WebController_macOS: NSViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var preloader: NSProgressIndicator?
    
    private var currentRequest: URLRequest?
    private var onResult: ((WebControllerResult) -> ())?
    private var onDismiss: (() -> ())?

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
        webView?.navigationDelegate = self
        preloader?.isDisplayedWhenStopped = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        onDismiss?()
    }
    
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> (), onDismiss: @escaping () -> ()) {
        self.currentRequest = urlRequest
        self.onResult = onResult
        self.onDismiss = onDismiss
        
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
        DispatchQueue.main.async {
            self.dismiss(nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        preloader?.stopAnimation(nil)
        onResult?(.response(webView.url))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onResult?(.error(error))
    }
}
