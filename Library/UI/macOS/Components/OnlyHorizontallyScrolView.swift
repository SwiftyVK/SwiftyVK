import Cocoa

class OnlyHorizontallyScrolView: NSScrollView {
    
    private var positionAxisX: CGFloat = 0
    private var positionAxisY: CGFloat = 0

    override func scrollWheel(with event: NSEvent) {
        if event.deltaX != positionAxisX {
            super.scrollWheel(with: event)
        }
        else if event.deltaY != positionAxisY {
            nextResponder?.scrollWheel(with: event)
        }
        
        positionAxisX = event.deltaX
        positionAxisY = event.deltaY
    }
}
