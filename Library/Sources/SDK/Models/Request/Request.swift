public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    private var nexts: [((Data) -> Request)] = []
    
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
        nexts = [next] + nexts
    }
    
    func next(with data: Data) -> Request? {
        let nextRequest = nexts.popLast()?(data)
        nextRequest?.nexts = nexts
        return nextRequest
    }
    
    func toMethod() -> Methods.SuccessableFailableProgressableConfigurable {
        return .init(self)
    }
}
