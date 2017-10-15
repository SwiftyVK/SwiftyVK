import Cocoa
import WebKit

final class WebViewWrapperMacOs: NSView {
    let webView: WKWebView
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        super.init(coder: coder)
        addSubview(webView)
    }
    
    override func layout() {
        super.layout()
        webView.frame = bounds
    }
}
