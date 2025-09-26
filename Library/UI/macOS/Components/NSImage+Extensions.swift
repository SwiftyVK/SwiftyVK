#if os(macOS)
import Cocoa

extension NSImage {
    
    var squared: NSImage {
        let sideSize = size.width > size.height ? size.height : size.width
        
        let originalRect = NSRect(
            x: (size.width - sideSize) / 2,
            y: (size.height - sideSize) / 2,
            width: sideSize,
            height: sideSize
        )
        
        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: sideSize,
            height: sideSize
        )
        
        let squaredImage = NSImage(size: targetRect.size)
        
        squaredImage.lockFocus()
        
        draw(
            in: targetRect,
            from: originalRect,
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: true,
            hints: nil
        )
        
        squaredImage.unlockFocus()
        
        return squaredImage
    }
}

#endif
