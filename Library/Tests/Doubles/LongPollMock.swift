@testable import SwiftyVK
import XCTest

final class LongPollMock: LongPoll {
    var isActive: Bool = false
    
    var onStart: (() -> ())?
    
    func start(onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        isActive = true
        onStart?()
    }
    
    var onStop: (() -> ())?
    
    func stop() {
        isActive = false
        onStop?()
    }
}
