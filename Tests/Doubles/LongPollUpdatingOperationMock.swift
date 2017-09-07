@testable import SwiftyVK
import XCTest

class LongPollUpdatingOperationMock: Operation, LongPollUpdatingOperation {
    
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
