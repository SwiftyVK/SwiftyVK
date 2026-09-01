#if os(macOS)
import Cocoa

class FlippedClipView: NSClipView {
    override var isFlipped: Bool { true }
}

#endif
