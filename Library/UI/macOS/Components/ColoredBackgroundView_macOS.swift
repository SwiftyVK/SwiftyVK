import Cocoa

@IBDesignable
final class ColoredBackgroundViewMacOS: NSView {
    
    @IBInspectable var backgroundColor: NSColor = .clear {
        didSet {
            wantsLayer = true
            layer?.backgroundColor = backgroundColor.cgColor
            needsDisplay = true
            
        }
    }
}
