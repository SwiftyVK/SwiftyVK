protocol Dependencies:
    DependenciesHolder,
    SessionMaker,
    TaskMaker,
    AttemptMaker,
    TokenMaker,
    WebControllerMaker,
    CaptchaControllerMaker,
    LongPollTaskMaker,
    LongPollMaker { }

protocol DependenciesHolder: SessionsHolderHolder, AuthorizatorHolder {
    init(appId: String, delegate: SwiftyVKDelegate?)
}

protocol SessionsHolderHolder: class {
    var sessionsHolder: SessionsHolder & SessionSaver { get }
}

protocol AuthorizatorHolder: class {
    var authorizator: Authorizator { get }
}

protocol SessionMaker: class {
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session
}

protocol TaskMaker: class {
    func task(request: Request, session: TaskSession & ApiErrorExecutor) -> Task
}

protocol AttemptMaker: class {
    func attempt(request: URLRequest, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker: class {
    func token(token: String, expires: TimeInterval, info: [String: String]) -> Token
}

protocol WebControllerMaker: class {
    func webController() -> WebController?
}

protocol CaptchaControllerMaker: class {
    func captchaController() -> CaptchaController?
}

protocol LongPollTaskMaker: class {
    func longPollTask(session: Session?, data: LongPollTaskData) -> LongPollTask
}

protocol LongPollMaker: class {
    func longPoll(session: Session) -> LongPoll
}
