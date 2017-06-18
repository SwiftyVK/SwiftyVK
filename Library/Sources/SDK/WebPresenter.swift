protocol WebPresenter: class {
    func presentWith(urlRequest: URLRequest) throws -> String
    func dismiss()
}

enum WebControllerResult {
    case response(URL?)
    case error(Error)
}

private enum WebPresenterResult {
    case response(String)
    case error(Error)
}

final class WebPresenterImpl: WebPresenter {
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: WebControllerMaker
    private weak var currentController: WebController?
    private let maxFails: Int
    private let timeout: TimeInterval

    init(
        uiSyncQueue: DispatchQueue,
        controllerMaker: WebControllerMaker,
        maxFails: Int,
        timeout: TimeInterval
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controllerMaker = controllerMaker
        self.maxFails = maxFails
        self.timeout = timeout
    }
    
    func presentWith(urlRequest: URLRequest) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var fails: Int = 0
        var result: WebPresenterResult?
        
        return try uiSyncQueue.sync {
            
            guard let controller = controllerMaker.webController() else {
                throw SessionError.cantMakeWebViewController
            }
            
            currentController = controller
            
            controller.load(
                urlRequest: urlRequest,
                onResult: { [weak self] controllerResult in
                    do {
                        if let handledResult = try self?.handle(result: controllerResult, fails: &fails) {
                            result = .response(handledResult)
                        }
                    } catch let error {
                        result = .error(error)
                    }
                    
                    if result != nil {
                        self?.currentController?.dismiss()
                    }
                },
                onDismiss: {
                    semaphore.signal()
                }
            )
            
            switch semaphore.wait(timeout: .now() + timeout) {
            case .timedOut:
                throw SessionError.webPresenterTimedOut
            case .success:
                break
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
    
    private func handle(result: WebControllerResult, fails: inout Int) throws -> String? {
        switch result {
        case .response(let url):
            return try handle(url: url)
        case .error(let error):
            try handle(error: error, fails: &fails)
            return nil
        }
    }
    
    private func handle(url: URL?) throws -> String? {
        guard let url = url else {
            throw SessionError.wrongAuthUrl
        }
        
        let fragment = url.fragment ?? ""

        if fragment.contains("access_token=") {
            return fragment
        }
        else if fragment.contains("success=1") {
            return fragment
        }
        else if fragment.contains("access_denied") ||
            fragment.contains("cancel=1") {
            throw SessionError.deniedFromUser
        }
        else if fragment.contains("fail=1") {
            throw SessionError.failedAuthorization
        }
        else {
            currentController?.goBack()
            return nil
        }
    }
    
    private func handle(error: Error, fails: inout Int) throws {
        fails += 1

        guard fails >= maxFails else {
            currentController?.reload()
            return
        }
        
        throw error
    }
    
    func dismiss() {
        currentController?.dismiss()
    }
}
