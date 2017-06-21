@testable import SwiftyVK

final class DependencyHolderMock: DependencyHolder {
    
    init(appId: String, delegate: SwiftyVKDelegate?) {}
    
    var sessionsHolder: SessionSaver & SessionsHolder {
        return SessionsHolderMock()
    }
    
    var authorizator: Authorizator {
        return AuthorizatorMock()
    }
}

final class TaskMakerMock: TaskMaker {
    func task(request: Request, callbacks: Callbacks, session: ApiErrorExecutor & TaskSession) -> Task {
        return TaskMock()
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
