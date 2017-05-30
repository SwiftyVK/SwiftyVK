protocol WebPresenter: class {
    func presentWith(url: URL) throws -> String
    func dismiss()
}

protocol WebHandler: class {
    func handle(url: URL)
    func handle(error: Error)
}

final class WebPresenterImpl: WebPresenter, WebHandler {
    private let semaphore = DispatchSemaphore(value: 0)
    private var result: WebPresenterResult?
    private var canFinish = Atomic(true)
    private var fails: Int = 0
    
    private let controller: WebController

    init(controller: WebController) {
        self.controller = controller
    }
    
    func presentWith(url: URL) throws -> String {
        controller.load(url: url, handler: self)
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
    
    func handle(url: URL) {
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
        else if host.contains("vk.com") && (
            url.path == "/authorize" ||
            url.path == "/login" ||
            query.contains("act=security_check") ||
            query.contains("api_validation_test")) {
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
