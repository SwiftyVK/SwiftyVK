import UIKit

final class DisclosuredButtonIOS: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(
            x: contentRect.maxX - 25,
            y: contentRect.maxY - ((15 + contentRect.height) / 2),
            width: 10,
            height: 15
        )
    }
}
