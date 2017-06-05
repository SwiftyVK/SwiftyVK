import UIKit
import WebKit

final class WebController_iOS: UIViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webView: VKWebView?
    @IBOutlet private weak var preloader: UIActivityIndicatorView?
    
    private weak var handler: WebHandler?
    private var currentRequest: URLRequest?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView?.layer.cornerRadius = 15
        webView?.clipsToBounds = true
        webView?.layer.borderWidth = 1 / UIScreen.main.nativeScale
        webView?.layer.borderColor = UIColor.lightGray.cgColor
        webView?.navigationDelegate = self
        preloader?.color = .lightGray
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

// Hack to represent WKWebView in XIB :)
class VKWebView: WKWebView {
    
    required init?(coder: NSCoder) {
        if let _view = UIView(coder: coder) {
            super.init(frame: _view.frame, configuration: WKWebViewConfiguration())
            self.translatesAutoresizingMaskIntoConstraints = false
        } else {
            return nil
        }
    }
}
