@testable import SwiftyVK

final class DependencyHolderMock: DependencyHolder {
    
    init(appId: String, delegate: SwiftyVKDelegate?) {}
    
    private let sessionsHolderMock = SessionsHolderMock()
    
    var sessionsHolder: SessionSaver & SessionsHolder {
        return sessionsHolderMock
    }
    
    private let authorizatorMock = AuthorizatorMock()
    
    var authorizator: Authorizator {
        return authorizatorMock
    }
}

final class TaskMakerMock: TaskMaker {
    func task(request: Request, callbacks: RequestCallbacks, session: ApiErrorExecutor & TaskSession) -> Task {
        return TaskMock()
    }
}

final class AttemptMakerMock: AttemptMaker {
    
    var onMake: ((_ callbacks: AttemptCallbacks) -> Attempt)?
    
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt {
        return onMake?(callbacks) ?? AttemptMock()
    }
}

final class SessionMakerMock: SessionMaker {
    
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session {
        return SessionMock()
    }
}

final class TokenMakerMock: TokenMaker {
    
    var onMake: ((String, TimeInterval, [String : String]) -> Token)?
    
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token {
        return onMake?(token, expires, info) ?? TokenMock()
    }
}

final class WebControllerMakerMock: WebControllerMaker {
    
    var onMake: (() -> WebController?)?
    
    func webController() -> WebController? {
        return onMake?()
    }
}

final class CaptchaControllerMakerMock: CaptchaControllerMaker {
    
    var onMake: (() -> CaptchaController?)?
    
    func captchaController() -> CaptchaController? {
        return onMake?()
    }
}
