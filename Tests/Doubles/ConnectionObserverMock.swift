@testable import SwiftyVK
import XCTest

final class ConnectionObserverMock: ConnectionObserver {
    
    var onSetUp: ((() -> (), () -> ()) -> ())?
    
    func setUp(onConnect: @escaping () -> (), onDisconnect: @escaping () -> ()) {
        onSetUp?(onConnect, onDisconnect)
    }
}
