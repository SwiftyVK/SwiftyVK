import XCTest
@testable import SwiftyVK

final class DependenciesHolderMock: DependenciesHolder {
    
    var onInit: ((String, SwiftyVKDelegate?) -> ())?
    
    init(appId: String, delegate: SwiftyVKDelegate?) {
        onInit?(appId, delegate)
    }
    
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
        let session = SessionMock()
        session.config = config
        return session
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
    
    var onMake: (() -> WebController)?
    
    func webController(onDismiss: (() -> ())?) -> WebController {
        guard let result = onMake?() else {
            XCTFail("onMake not defined")
            return WebControllerMock()
        }
        
        result.onDismiss = onDismiss
        return result
    }
}

final class CaptchaControllerMakerMock: CaptchaControllerMaker {
    
    var onMake: (() -> CaptchaController)?
    
    func captchaController(onDismiss: (() -> ())?) -> CaptchaController {
        guard let result = onMake?() else {
            XCTFail("onMake not defined")
            return CaptchaControllerMock()
        }
        
        let prevOnDismiss = result.onDismiss
        
        result.onDismiss = {
            prevOnDismiss?()
            onDismiss?()
        }
        return result
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

final class SharePresenterMakerMock: SharePresenterMaker {
    
    var onMake: (() -> SharePresenter)?
    
    func sharePresenter() -> SharePresenter {
        guard let result = onMake?() else {
            XCTFail("onMake not defined")
            return SharePresenterMock()
        }
        
        return result
    }
}

final class ShareControllerMakerMock: ShareControllerMaker {
    
    var onMake: (((() -> ())?) -> ShareController)?
    
    func shareController(onDismiss: (() -> ())?) -> ShareController {
        guard let result = onMake?(onDismiss) else {
            XCTFail("onMake not defined")
            return ShareControllerMock()
        }
        
        return result
    }
}
