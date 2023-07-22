@testable import SwiftyVK

final class SessionMock: Session, TaskSession, DestroyableSession, ApiErrorExecutor {

    var accessToken: Token?
    
    var longPoll: LongPoll = LongPollMock()
    
    var token: InvalidatableToken?
    
    let id = String.random(20)
    var config = SessionConfig()
    var state = SessionState.initiated
    var isDefault = false
    
    init() {
        
    }
    
    func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping RequestCallbacks.Error) {
        
    }
    
    func logIn(rawToken: String, expires: TimeInterval) throws {
        
    }
    
    func logInCode(onSuccess: @escaping ([String : String]) -> (), onError: @escaping RequestCallbacks.Error) {
        
    }
    
    var onInvalidate: (() -> ())?
    
    func invalidate() {
        onInvalidate?()
    }
    
    func logOut() {}
    
    var onSend: ((SendableMethod) -> ())?
    
    @discardableResult
    func send(method: SendableMethod) -> Task {
        onSend?(method)
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
    
    func logIn(revoke: Bool) throws -> [String : String] {
        return [:]
    }
    
    func validate(redirectUrl: URL) throws {
        
    }
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws -> String {
        return ""
    }
    
    func share(_ context: ShareContext, onSuccess: @escaping RequestCallbacks.Success, onError: @escaping RequestCallbacks.Error) {
    }
    
    func share(_ context: ShareContext, onSuccess: @escaping ([String : Any]) throws -> (), onError: @escaping RequestCallbacks.Error) {
    }
}
