import Cocoa

final class MultilineTextFieldMacOS: NSTextField, NSTextFieldDelegate {
    private let bottomSpace: CGFloat = 5
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: NSSize {
        let superIntrinsic = super.intrinsicContentSize
        
        guard
        let textView = self.window?.fieldEditor(false, for: self) as? NSTextView,
        let container = textView.textContainer
            else { return superIntrinsic }
        
        guard
            let newHeight = container.layoutManager?.usedRect(for: container).height
            else { return superIntrinsic }
        
        var newSize = super.intrinsicContentSize
        newSize.height = newHeight + bottomSpace
        
        return newSize
    }
}
