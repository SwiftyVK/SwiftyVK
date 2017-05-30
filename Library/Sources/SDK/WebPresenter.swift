protocol WebPresenter: class {
    func presentWith(url: URL) throws -> String
    func dismiss()
}

protocol WebHandler: WebPresenter {
    func handle(response: String)
    func handle(error: Error)
}

final class WebPresenterImpl: WebHandler {
    private let semaphore = DispatchSemaphore(value: 0)
    private var result: WebPresenterResult?
    private var canFinish = Atomic(true)
    private var fails: Int = 0
    
    private let controller: WebController

    init(controller: WebController) {
        self.controller = controller
    }
    
    func presentWith(url: URL) throws -> String {
        try controller.load(url: url, handler: self)
        semaphore.wait()
        
        switch result {
        case .response(let response)?:
            return response
        case .error(let error)?:
            throw error
        case nil:
            throw SessionError.webPresenterResultIsNil
        }
    }
    
    func handle(response: String) {
        if response.contains("access_token=") {
            finishWith(.response(response))
        }
        else if response.contains("success=1") {
            finishWith(.response(response))
        }
        else if response.contains("access_denied") ||
            response.contains("cancel=1") {
            finishWith(.error(SessionError.deniedFromUser))
        }
        else if response.contains("fail=1") {
            finishWith(.error(SessionError.failedAuthorization))
        }
        else if response.contains("https://oauth.vk.com/authorize?") ||
            response.contains("act=security_check") ||
            response.contains("api_validation_test") ||
            response.contains("https://m.vk.com/login?") {
            controller.expand()
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
