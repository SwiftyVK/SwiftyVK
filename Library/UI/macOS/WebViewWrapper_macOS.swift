#if os(macOS)
import Cocoa
import WebKit

final class WebViewWrapperMacOs: NSView {
    let webView: WKWebView
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        if #available(macOS 10.11, *) {
            webView.customUserAgent = WebViewUserAgent.mobileSafari
        }
        super.init(coder: coder)
        addSubview(webView)
    }
    
    override func layout() {
        super.layout()
        webView.frame = bounds
    }
}

#endif
