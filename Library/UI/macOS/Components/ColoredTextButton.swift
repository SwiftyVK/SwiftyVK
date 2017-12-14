import Cocoa

@IBDesignable
class ColoredTextButton: NSButton {
    
    @IBInspectable var titleColor: NSColor = .white
    @IBInspectable var alternateTitleColor: NSColor = .lightGray
    @IBInspectable var fontSize: CGFloat = 16
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: titleColor,
                .font: NSFont.systemFont(ofSize: fontSize)
            ]
        )
        
        attributedAlternateTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: alternateTitleColor,
                .font: NSFont.systemFont(ofSize: fontSize)
            ]
        )
    }
}
