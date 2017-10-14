@testable import SwiftyVK
import XCTest

class LongPollTaskMock: Operation, LongPollTask {
    
    var onMain: (() -> ())?
    
    override func main() {
        onMain?()
    }
    
    var onCancel: (() -> ())?
    
    override func cancel() {
        super.cancel()
        onCancel?()
    }
}
