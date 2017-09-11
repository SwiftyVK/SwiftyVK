@testable import SwiftyVK
import XCTest

final class ConnectionObserverMock: ConnectionObserver {
    
    var onSubscribe: ((AnyObject, ConnectionUpdate) -> ())?
    
    func subscribe(object: AnyObject, callbacks: ConnectionUpdate) {
        onSubscribe?(object, callbacks)
    }
    
    var onUnsubscribe: ((AnyObject) -> ())?
    
    func unsubscribe(object: AnyObject) {
        onUnsubscribe?(object)
    }
}
