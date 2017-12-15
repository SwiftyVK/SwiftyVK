import UIKit

final class DisclosuredButtonIOS: UIButton {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(
            x: contentRect.minX + 15,
            y: contentRect.minY,
            width: contentRect.width,
            height: contentRect.height
        )
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(
            x: contentRect.maxX - 25,
            y: contentRect.maxY - ((15 + contentRect.height) / 2),
            width: 10,
            height: 15
        )
    }
}
