public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    var nexts: [((Data) -> Request)] = []
    
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
    
    func toMethod() -> Methods.Basic {
        return Methods.Basic(self)
    }
}
