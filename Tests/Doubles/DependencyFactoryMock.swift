@testable import SwiftyVK

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
