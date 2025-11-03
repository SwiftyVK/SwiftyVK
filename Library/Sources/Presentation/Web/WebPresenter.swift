import Foundation

protocol WebPresenter: AnyObject {
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

private enum ResponseParsingResult {
    case response(String)
    case fail
    case nothing
    case wrongPage
}

private final class LoadingState {
    var originalPath: String
    var fails: Int = 0
    var result: WebPresenterResult?
    
    init(originalPath: String) {
        self.originalPath = originalPath
    }
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
    
    func presentWith(urlRequest: URLRequest) throws -> String {
        guard let controllerMaker = controllerMaker else { throw VKError.weakObjectWasDeallocated }

        let semaphore = DispatchSemaphore(value: 0)
        let state = LoadingState(originalPath: urlRequest.url?.path ?? "")
        
        return try uiSyncQueue.sync {
            let controller = controllerMaker.webController {
                semaphore.signal()
            }
            
            // This is a hack to avoid crash while WebKit deinitializing not in the main thread
            // https://github.com/SwiftyVK/SwiftyVK/issues/142
            defer { releaseInMainThreadAfterDelay(controller) }
            
            currentController = controller
            
            controller.load(
                urlRequest: urlRequest,
                onResult: { [weak self] in
                    self?.handle(
                        result: $0,
                        state: state
                    )
                }
            )
            
            switch semaphore.wait(timeout: .now() + timeout) {
            case .timedOut:
                throw VKError.webPresenterTimedOut
            case .success:
                break
            }
            
            switch state.result {
            case .response(let response)?:
                return response
            case .error(let error)?:
                throw error
            case nil:
                throw VKError.webPresenterResultIsNil
            }
        }
    }
    
    private func handle(result: WebControllerResult, state: LoadingState) {
        do {
            let parsedResult: ResponseParsingResult
            
            switch result {
            case .response(let url):
                parsedResult = try parse(url: url, originalPath: state.originalPath)
            case .error(let error):
                parsedResult = try parse(error: error, fails: state.fails)
            }
            
            switch parsedResult {
            case let .response(value):
                state.result = .response(value)
                
            case .fail:
                state.fails += 1
                currentController?.reload()
                
            case .nothing:
                break
                
            case .wrongPage:
                currentController?.goBack()
            }
        }
            
        catch let error {
            state.result = .error(error.toVK())
        }
        
        if state.result != nil {
            currentController?.dismiss()
        }
    }
    
    private func parse(url maybeUrl: URL?, originalPath: String) throws -> ResponseParsingResult {
        guard let url = maybeUrl else {
            throw VKError.authorizationUrlIsNil
        }
                
        let host = url.host ?? ""
        let fragment = url.fragment ?? ""
        let query = url.query ?? ""
        
        if !VKDomains.allowedAuthHosts.contains(host) {
            return .wrongPage
        }
        if fragment.isEmpty && query.isEmpty {
            return .fail
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
    
    private func parse(error: VKError, fails: Int) throws -> ResponseParsingResult {
        if case .authorizationCancelled = error {
            throw error
        }
        
        guard fails >= maxFails - 1 else {
            return .fail
        }
        
        throw error
    }
    
    private func releaseInMainThreadAfterDelay(_ controller: WebController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            controller.dismiss()
        }
    }
    
    func dismiss() {
        currentController?.dismiss()
    }
}
