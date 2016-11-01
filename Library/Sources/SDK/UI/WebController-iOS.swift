import UIKit
import WebKit



private let WebViewName = Resources.withSuffix("WebView")



internal final class WebController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet fileprivate weak var webView : UIWebView?
    @IBOutlet fileprivate weak var activity : UIActivityIndicatorView!
    fileprivate var parentView : UIViewController?
    private weak var delegate: WebPresenter!
    private var url: String?
    
    
    
    class func create(withDelegate delegate: WebPresenter) -> WebController? {
        
        guard let parentView = VK.delegate?.vkWillPresentView() else {
            return nil
        }
        
        var controller: WebController!
        
        DispatchQueue.main.sync {
            controller              = WebController(nibName: WebViewName, bundle: Resources.bundle)
            controller.delegate     = delegate
            controller.parentView   = parentView
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            controller.parentView?.present(controller, animated: true, completion: nil)
        }
        
        return controller
    }
    
    
    
    override func viewDidLoad() {
        webView!.delegate = self
        super.viewDidLoad()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.finish()
    }
    
    
    
    func load(url: String) {
        if self.url == nil {
            self.url = url
        }
        
        DispatchQueue.main.sync {
            self.webView?.loadRequest(URLRequest(url: URL(string: self.url!)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3))
        }
    }
    
    
    
    func expand() {}
    
    
    
    func goBack() {
        webView?.goBack()
    }
    
    
    
    func hide() {
        self.parentView?.dismiss(animated: true, completion: nil)
        self.webView!.delegate = nil
    }
    
    
    
    //MARK: frameLoadDelegate protocol
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activity.stopAnimating()
        delegate?.handleResponse(webView.request!.url!.absoluteString)
    }
    
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        delegate?.handleError(.failedAuthorization)
    }
}
