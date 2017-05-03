@testable import SwiftyVK

final class SessionMock: Session {
    
    public static var `default`: Session = VK.dependencyBox.defaultSession
    
    public static func new() -> Session {
        return SessionMock()
    }
    
    public func send(request: SwiftyVK.Request, callbacks: SwiftyVK.Callbacks) -> Task {
        return TaskMock()
    }
}
