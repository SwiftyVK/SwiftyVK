public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    private var nextRequests: [((Data) -> Request)] = []
    
    init(
        type: RequestType,
        config: Config = .default,
        callbacks: RequestCallbacks = .empty
        ) {
        self.type = type
        self.config = config
        self.callbacks = callbacks
    }
    
    func add(next: @escaping ((Data) -> Request)) {
        nextRequests = [next] + nextRequests
    }
    
    func next(with data: Data) -> Request? {
        guard let next = nextRequests.popLast()?(data) else {
            return nil
        }
        
        next.callbacks = RequestCallbacks(
            onSuccess: callbacks.onSuccess,
            onError: callbacks.onError,
            onProgress: next.callbacks.onProgress
        )
        
        next.config = config.overriden(with: next.config)
        next.nextRequests = nextRequests
        
        return next
    }
    
    func toMethod() -> Methods.SuccessableFailableProgressableConfigurable {
        return .init(self)
    }
}
