#if os(iOS)
import UIKit
import WebKit

final class WebViewWrapperIOS: UIView {
    let webView: WKWebView
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.customUserAgent = WebViewUserAgent.mobileSafari
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

#endif
