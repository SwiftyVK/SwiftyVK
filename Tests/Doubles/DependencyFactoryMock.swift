import XCTest
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
    func task(request: Request, session: ApiErrorExecutor & TaskSession) -> Task {
        return TaskMock()
    }
}

final class AttemptMakerMock: AttemptMaker {
    
    var onMake: ((_ callbacks: AttemptCallbacks) -> Attempt)?
    
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt {
        guard let result = onMake?(callbacks) else {
            XCTFail("onMake not defined")
            return AttemptMock()
        }
        
        return result
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
        guard let result = onMake?(token, expires, info) else {
            XCTFail("onMake not defined")
            return TokenMock()
        }
        
        return result
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

final class LongPollUpdatingOperationMakerMock: LongPollUpdatingOperationMaker {
    
    var onMake: ((Session?, LongPollOperationData) -> LongPollUpdatingOperation)?
    
    func longPollUpdatingOperation(
        session: Session?,
        data: LongPollOperationData
        ) -> LongPollUpdatingOperation {
        guard let result = onMake?(session, data) else {
            XCTFail("onMake not defined")
            return LongPollUpdatingOperationMock()
        }
        
        return result
    }
}
