import Cocoa

final class MultilineTextFieldMacOS: NSTextField, NSTextFieldDelegate {
    private let bottomSpace: CGFloat = 5
    private var lastSize: NSSize?
    private var isEditing = false
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        isEditing = true
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        isEditing = false
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: NSSize {
        let superIntrinsic = super.intrinsicContentSize
        
        if isEditing || lastSize == nil {
            guard
                let textView = self.window?.fieldEditor(false, for: self) as? NSTextView,
                let container = textView.textContainer,
                let newHeight = container.layoutManager?.usedRect(for: container).height
                else {
                    return lastSize ?? superIntrinsic
            }
            
            var newSize = super.intrinsicContentSize
            newSize.height = newHeight + bottomSpace
            
            lastSize = newSize
            return newSize
        }
        else {
            return lastSize ?? superIntrinsic
        }
    }
}
