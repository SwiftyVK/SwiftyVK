protocol WebPresenter: class {
    func presentWith(urlRequest: URLRequest) throws -> String
    func dismiss()
}

protocol WebHandler: class {
    func handle(url: URL?)
    func handle(error: Error)
}

final class WebPresenterImpl: WebPresenter, WebHandler {
    private let semaphore = DispatchSemaphore(value: 0)
    private var result: WebPresenterResult?
    private var canFinish = Atomic(true)
    private var fails: Int = 0
    
    private let uiSyncQueue: DispatchQueue
    private let controller: WebController

    init(
        uiSyncQueue: DispatchQueue,
        controller: WebController
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controller = controller
    }
    
    func presentWith(urlRequest: URLRequest) throws -> String {
        return try uiSyncQueue.sync {
            self.controller.load(urlRequest: urlRequest, handler: self)
            
            switch semaphore.wait(timeout: .now() + 60) {
            case .success:
                break
            case .timedOut:
                throw SessionError.webPresenterTimedOut
            }
            
            switch result {
            case .response(let response)?:
                return response
            case .error(let error)?:
                throw error
            case nil:
                throw SessionError.webPresenterResultIsNil
            }
        }
    }
    
    func handle(url: URL?) {
        
        guard let url = url else {
            finishWith(.error(SessionError.wrongAuthUrl))
            return
        }
        
        let host = url.host ?? ""
        let query = url.query ?? ""
        let fragment = url.fragment ?? ""
        
        guard !host.isEmpty && (!query.isEmpty || !fragment.isEmpty) else {
            finishWith(.error(SessionError.wrongAuthUrl))
            return
        }

        if fragment.contains("access_token=") {
            finishWith(.response(fragment))
        }
        else if fragment.contains("success=1") {
            finishWith(.response(fragment))
        }
        else if fragment.contains("access_denied") ||
            fragment.contains("cancel=1") {
            finishWith(.error(SessionError.deniedFromUser))
        }
        else if fragment.contains("fail=1") {
            finishWith(.error(SessionError.failedAuthorization))
        }
        else {
            controller.goBack()
        }
    }
    
    func handle(error: Error) {
        guard fails > 3 else {
            fails += 1
            controller.reload()
            return
        }
        
        finishWith(.error(error))
    }
    
    func dismiss() {
        finishWith(nil)
    }
    
    private func finishWith(_ result: WebPresenterResult?) {
        canFinish >< { canFinish in
            guard canFinish else {
                return false
            }
            
            self.result = result
            self.controller.dismiss()
            self.semaphore.signal()
            return false
        }
    }
}

private enum WebPresenterResult {
    case response(String)
    case error(Error)
}
