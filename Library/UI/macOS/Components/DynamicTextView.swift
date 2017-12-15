import Cocoa

class DynamicTextView: NSTextView {
    
    override var string: String {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: NSSize {
        guard let container = textContainer else { return .zero }
        container.layoutManager?.ensureLayout(for: container)
        return container.layoutManager?.usedRect(for: container).size ?? .zero
    }
    
    override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
    }
}
