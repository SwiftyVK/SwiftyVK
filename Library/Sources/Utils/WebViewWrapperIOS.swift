import UIKit
import WebKit

class WebViewWrapperIOS: UIView {
    let webView: WKWebView
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        super.init(coder: coder)
        addSubview(webView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }
}

