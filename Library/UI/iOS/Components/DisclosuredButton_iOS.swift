#if os(iOS)
import UIKit

final class DisclosuredButtonIOS: UIButton {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(
            x: contentRect.minX + 15,
            y: contentRect.minY,
            width: contentRect.width,
            height: contentRect.height
        )
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(
            x: contentRect.maxX - 25,
            y: contentRect.maxY - ((15 + contentRect.height) / 2),
            width: 10,
            height: 15
        )
    }
}

final class ExtendedInsetsButtonIOS: UIButton {

    @IBInspectable var extendedInsets: CGFloat = 0

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard extendedInsets > 0 else {
            return super.point(inside: point, with: event)
        }

        return bounds.insetBy(dx: -extendedInsets, dy: -extendedInsets).contains(point)
    }
}

#endif
