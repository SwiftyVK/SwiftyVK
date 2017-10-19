/// SwiftyVK internal representation of request
public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    private var nextRequests: [((Data) throws -> ChainableMethod)] = []
    
    var canSentConcurrently: Bool {
        switch type {
        case .api:
            return false
        case .url, .upload:
            return true
        }
    }
    
    init(
        type: RequestType,
        config: Config = .default,
        callbacks: RequestCallbacks = .empty
        ) {
        self.type = type
        self.config = config
        self.callbacks = callbacks
    }
    
    func add(next: @escaping ((Data) throws -> ChainableMethod)) {
        nextRequests = [next] + nextRequests
    }
    
    func next(with data: Data) throws -> Request? {
        guard let nextMethod = nextRequests.popLast() else {
            return nil
        }
        
        let nextRequest = try nextMethod(data).toRequest()
        
        nextRequest.callbacks = RequestCallbacks(
            onSuccess: callbacks.onSuccess,
            onError: callbacks.onError,
            onProgress: callbacks.onProgress
        )
        
        nextRequest.config = config.overriden(with: nextRequest.config)
        nextRequest.nextRequests = nextRequests
        
        return nextRequest
    }
    
    func toMethod() -> Methods.SuccessableFailableProgressableConfigurable {
        return .init(self)
    }
}
