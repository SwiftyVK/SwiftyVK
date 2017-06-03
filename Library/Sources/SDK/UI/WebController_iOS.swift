import UIKit
import WebKit

final class WebController_iOS: UIViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var preloader: UIActivityIndicatorView?
    
    private weak var handler: WebHandler?
    private var currentRequest: URLRequest?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView?.navigationDelegate = self
        preloader?.hidesWhenStopped = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func load(urlRequest: URLRequest, handler: WebHandler) {
        self.handler = handler
        self.currentRequest = urlRequest
    
        preloader?.startAnimating()
        loadCurrentRequest()
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
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        preloader?.stopAnimating()
        handler?.handle(url: webView.url)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handler?.handle(error: error)
    }
}
