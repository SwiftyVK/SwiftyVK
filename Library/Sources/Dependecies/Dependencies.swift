import Foundation

protocol Dependencies:
    DependenciesHolder,
    SessionMaker,
    TaskMaker,
    AttemptMaker,
    TokenMaker,
    WebControllerMaker,
    CaptchaControllerMaker,
    LongPollTaskMaker,
    LongPollMaker,
    SharePresenterMaker,
    ShareControllerMaker { }

protocol DependenciesHolder: SessionsHolderHolder, AuthorizatorHolder {
    init(appId: String, delegate: SwiftyVKDelegate?, bundleName: String?, configPath: String?)
}

extension DependenciesHolder {
    init(appId: String, delegate: SwiftyVKDelegate?) {
        self.init(appId: appId, delegate: delegate, bundleName: nil, configPath: nil)
    }
}

protocol SessionsHolderHolder: AnyObject {
    var sessionsHolder: SessionsHolder & SessionSaver { get }
}

protocol AuthorizatorHolder: AnyObject {
    var authorizator: Authorizator { get }
}

protocol SessionMaker: AnyObject {
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session
}

protocol TaskMaker: AnyObject {
    func task(request: Request, session: TaskSession & ApiErrorExecutor) -> Task
}

protocol AttemptMaker: AnyObject {
    func attempt(request: URLRequest, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker: AnyObject {
    func token(token: String, expires: TimeInterval, info: [String: String]) -> InvalidatableToken
}

protocol WebControllerMaker: AnyObject {
    func webController(onDismiss: (() -> ())?) -> WebController
}

protocol CaptchaControllerMaker: AnyObject {
    func captchaController(onDismiss: (() -> ())?) -> CaptchaController
}

protocol ShareControllerMaker: AnyObject {
    func shareController(onDismiss: (() -> ())?) -> ShareController
}

protocol LongPollTaskMaker: AnyObject {
    func longPollTask(session: Session?, data: LongPollTaskData) -> LongPollTask
}

protocol LongPollMaker: AnyObject {
    func longPoll(session: Session) -> LongPoll
}

protocol SharePresenterMaker: AnyObject {
    func sharePresenter() -> SharePresenter
}
