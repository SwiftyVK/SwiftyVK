@testable import SwiftyVK

final class DependencyHolderMock: DependencyHolder {
    
    init(appId: String, delegate: SwiftyVKDelegate?) {}
    
    var sessionStorage: SessionStorage {
        return SessionStorageMock()
    }
    
    var authorizator: Authorizator {
        return AuthorizatorMock()
    }
}

final class TaskMakerMock: TaskMaker {
    func task(request: Request, callbacks: Callbacks, token: Token?, attemptSheduler: AttemptSheduler) -> Task {
        return TaskMock()
    }
}


final class SessionMakerMock: SessionMaker {
    func session() -> Session {
        return SessionMock()
    }
}

final class TokenMakerMock: TokenMaker {
    
    var onMake: ((String, TimeInterval, [String : String]) -> Token)?
    
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token {
        return onMake?(token, expires, info) ?? TokenMock()
    }
}

final class WebPresenterMakerMock: WebPresenterMaker {
    
    var onMake: (() -> WebPresenter?)?
    
    func webPresenter() -> WebPresenter? {
        return onMake?()
    }
}
