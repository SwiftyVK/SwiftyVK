import Cocoa

class OnePixelConstraintMacOS: NSLayoutConstraint {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constant = 1 / (NSScreen.main?.backingScaleFactor ?? 1)
    }
}

