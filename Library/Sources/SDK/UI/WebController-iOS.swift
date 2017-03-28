#if os(iOS)
    import UIKit
    import WebKit
    
    
    
    private let webViewName = Resources.withSuffix("WebView")
    
    
    
    internal final class WebController: UIViewController, UIWebViewDelegate {
        
        @IBOutlet private weak var webView: UIWebView?
        @IBOutlet private weak var activity: UIActivityIndicatorView!
        fileprivate var parentView: UIViewController?
        private weak var delegate: WebPresenter!
        private var url: String?
        
        
        
        class func create(withDelegate delegate: WebPresenter) -> WebController? {
            
            guard let parentView = VK.delegate?.vkWillPresentView() else {
                return nil
            }
            
            var controller: WebController!
            
            DispatchQueue.main.sync {
                controller              = WebController(nibName: webViewName, bundle: Resources.bundle)
                controller.delegate     = delegate
                controller.parentView   = parentView
                controller.modalPresentationStyle = .overFullScreen
                controller.modalTransitionStyle = .crossDissolve
                controller.parentView?.present(controller, animated: true, completion: nil)
            }
            
            return controller
        }
        
        
        
        override func viewDidLoad() {
            webView?.delegate = self
            super.viewDidLoad()
        }
        
        
        
        override func viewDidDisappear(_ animated: Bool) {
            delegate?.finish()
            super.viewDidDisappear(animated)
        }
        
        
        
        func load(url: String) {
            if self.url == nil {
                self.url = url
            }
            
            guard let urlStr = self.url, let url = URL(string: urlStr) else {return}
            VK.Log.put("WebController", "load \(urlStr)")
            webView?.loadRequest(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10))
        }
        
        
        
        func expand() {}
        
        
        
        func goBack() {
            VK.Log.put("WebController", "goBack")
            
            webView?.goBack()
        }
        
        
        
        func hide() {
            VK.Log.put("WebController", "hide")
            
            self.parentView?.dismiss(animated: true, completion: nil)
            self.webView?.delegate = nil
        }
        
        
        
        // MARK: - frameLoadDelegate protocol
        func webViewDidFinishLoad(_ webView: UIWebView) {
            activity.stopAnimating()
            delegate?.handle(response: webView.request?.url?.absoluteString ?? "")
        }
        
        
        
        func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
            delegate?.handle(error: .failedAuthorization)
        }
    }
#endif
