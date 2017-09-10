@testable import SwiftyVK
import XCTest

final class ConnectionObserverMock: ConnectionObserver {
    
    var onSubscribe: ((AnyObject, ConnectionUpdate) -> ())?
    
    func subscribe(object: AnyObject, onUpdate: ConnectionUpdate) {
        onSubscribe?(object, onUpdate)
    }
    
    var onUnsubscribe: ((AnyObject) -> ())?
    
    func unsubscribe(object: AnyObject) {
        onUnsubscribe?(object)
    }
}
