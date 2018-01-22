import Foundation

protocol WebPresenter: class {
    func presentWith(urlRequest: URLRequest) throws -> String
    func dismiss()
}

enum WebControllerResult {
    case response(URL?)
    case error(VKError)
}

private enum WebPresenterResult {
    case response(String)
    case error(VKError)
}

private enum HandledResult {
    case response(String)
    case fail
    case nothing
}

final class WebPresenterImpl: WebPresenter {
    private let uiSyncQueue: DispatchQueue
    private weak var controllerMaker: WebControllerMaker?
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
    
    // swiftlint:disable cyclomatic_complexity next
    func presentWith(urlRequest: URLRequest) throws -> String {
        guard let controllerMaker = controllerMaker else { throw VKError.weakObjectWasDeallocated }

        let semaphore = DispatchSemaphore(value: 0)
        var fails: Int = 0
        var finalResult: WebPresenterResult?
        
        return try uiSyncQueue.sync {
            
            let controller = controllerMaker.webController {
                semaphore.signal()
            }
            
            let originalPath = urlRequest.url?.path ?? ""
            currentController = controller
            
            controller.load(
                urlRequest: urlRequest,
                onResult: { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    do {
                        let handledResult = try strongSelf.handle(
                            result: result,
                            fails: fails,
                            originalPath: originalPath
                        )
                        
                        switch handledResult {
                        case let .response(value):
                            finalResult = .response(value)
                        case .fail:
                            fails += 1
                            strongSelf.currentController?.reload()
                        case .nothing:
                            break
                        }
                        
                    }
                    catch let error {
                        finalResult = .error(error.toVK())
                    }
                    
                    if finalResult != nil {
                        strongSelf.currentController?.dismiss()
                    }
                }
            )
            
            switch semaphore.wait(timeout: .now() + timeout) {
            case .timedOut:
                throw VKError.webPresenterTimedOut
            case .success:
                break
            }
            
            switch finalResult {
            case .response(let response)?:
                return response
            case .error(let error)?:
                throw error
            case nil:
                throw VKError.webPresenterResultIsNil
            }
        }
    }
    
    private func handle(result: WebControllerResult, fails: Int, originalPath: String) throws -> HandledResult {
        switch result {
        case .response(let url):
            return try handle(url: url, originalPath: originalPath)
        case .error(let error):
            return try handle(error: error, fails: fails)
        }
    }
    
    private func handle(url maybeUrl: URL?, originalPath: String) throws -> HandledResult {
        guard let url = maybeUrl else {
            throw VKError.authorizationUrlIsNil
        }
        
        let host = url.host ?? ""
        let fragment = url.fragment ?? ""

        if host != "vk.com" && host != "m.vk.com" && host != "oauth.vk.com" {
            currentController?.goBack()
        }
        else if fragment.contains("access_token=") {
            return .response(fragment)
        }
        else if fragment.contains("success=1") {
            return .response(fragment)
        }
        else if fragment.contains("access_denied") {
            throw VKError.authorizationDenied
        }
        else if fragment.contains("cancel=1") {
            throw VKError.authorizationCancelled
        }
        else if fragment.contains("fail=1") {
            throw VKError.authorizationFailed
        }
        
        return .nothing
    }
    
    private func handle(error: VKError, fails: Int) throws -> HandledResult {
        if case .authorizationCancelled = error {
            throw error
        }
        
        guard fails >= maxFails - 1 else {
            return .fail
        }
        
        throw error
    }
    
    func dismiss() {
        currentController?.dismiss()
    }
}
