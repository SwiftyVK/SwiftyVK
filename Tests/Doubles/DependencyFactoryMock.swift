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
    
    func attempt(request: URLRequest, callbacks: AttemptCallbacks) -> Attempt {
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

final class LongPollTaskMakerMock: LongPollTaskMaker {
    
    var onMake: ((Session?, LongPollTaskData) -> LongPollTask)?
    
    func longPollTask(
        session: Session?,
        data: LongPollTaskData
        ) -> LongPollTask {
        guard let result = onMake?(session, data) else {
            XCTFail("onMake not defined")
            return LongPollTaskMock()
        }
        
        return result
    }
}

final class LongPollMakerMock: LongPollMaker {
    
    var onMake: ((Session) -> LongPoll)?

    func longPoll(session: Session) -> LongPoll {
        guard let result = onMake?(session) else {
            XCTFail("onMake not defined")
            return LongPollMock()
        }
        
        return result
    }

}
