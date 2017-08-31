@testable import SwiftyVK

final class SessionMock: Session, TaskSession, DestroyableSession {
    var token: Token?
    
    let id = String.random(20)
    var config = SessionConfig()
    var state = SessionState.initiated
    var isDefault = false
    
    init() {
        
    }
    
    func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping Callbacks.Error) {
        
    }
    
    func logIn(rawToken: String, expires: TimeInterval) throws {
        
    }
    
    func logOut() {}
    
    var onSend: ((Request) -> ())?
    
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task {
        onSend?(request)
        return TaskMock()
    }
    
    var onShedule: ((Attempt) throws -> ())?
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try onShedule?(attempt)
    }
    
    var onDismissCaptcha: (() -> ())?

    
    func dismissCaptcha() {
        onDismissCaptcha?()
    }
    
    func destroy() {
        state = .destroyed
    }
}
