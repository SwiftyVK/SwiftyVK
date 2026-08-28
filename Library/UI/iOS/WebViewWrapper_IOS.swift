#if os(iOS)
import UIKit
import WebKit

final class WebViewWrapperIOS: UIView {
    let webView: WKWebView
    var onClose: (() -> Void)?

    private let headerHeight: CGFloat = 44
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    
    public required init?(coder: NSCoder) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.customUserAgent = WebViewUserAgent.mobileSafari
        super.init(coder: coder)
        addSubview(webView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        subviews.compactMap { $0 as? UIToolbar }.forEach { $0.removeFromSuperview() }

        headerView.backgroundColor = UIColor(
            red: 0.3122879863,
            green: 0.4476459622,
            blue: 0.5988624692,
            alpha: 1
        )
        addSubview(headerView)

        closeButton.setTitle(Resources.localizedString(for: "Cancel"), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.contentHorizontalAlignment = .left
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        headerView.addSubview(closeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY + headerHeight,
            width: bounds.width,
            height: bounds.height - headerHeight
        )
        headerView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: bounds.width,
            height: headerHeight
        )
        closeButton.frame = headerView.bounds
    }

    @objc private func closePressed() {
        onClose?()
    }
}

#endif
