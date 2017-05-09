@testable import SwiftyVK

final class SessionMock: Session {
    
    var config = SessionConfig()
    
    public func send(request: SwiftyVK.Request, callbacks: SwiftyVK.Callbacks) -> Task {
        return TaskMock()
    }
}
