import Cocoa
import WebKit

final class WebControllerMacOS: NSViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webWrapper: WebViewWrapperMacOs?
    @IBOutlet private weak var preloader: NSProgressIndicator?
    
    private var currentRequest: URLRequest?
    private var onResult: ((WebControllerResult) -> ())?
    var onDismiss: (() -> ())?

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
        webWrapper?.webView.navigationDelegate = self
        preloader?.isDisplayedWhenStopped = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        onDismiss?()
    }
    
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> ()) {
        self.currentRequest = urlRequest
        self.onResult = onResult
        
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
        
        webWrapper?.webView.load(currentRequest)
    }
    
    func goBack() {
        webWrapper?.webView.goBack()
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        onResult?(.error(.authorizationCancelled))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        preloader?.stopAnimation(nil)
        onResult?(.response(webView.url))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
        onResult?(.error(.webControllerError(error)))
    }
}
