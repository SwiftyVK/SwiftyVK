import UIKit
import WebKit

final class WebViewWrapperIOS: UIView {
    let webView: WKWebView
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        super.init(coder: coder)
        addSubview(webView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY + 44,
            width: bounds.width,
            height: bounds.height - 44
        )
    }
}
