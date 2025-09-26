#if os(macOS)
import Cocoa

class FlippedClipView: NSClipView {
    override var isFlipped: Bool { return true }
}

#endif
