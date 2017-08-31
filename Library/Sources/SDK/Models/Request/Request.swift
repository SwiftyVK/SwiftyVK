public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    var nexts: [((Data) -> Request)]
    
    init(
        type: RequestType,
        config: Config = .default,
        callbacks: RequestCallbacks = .empty,
        nexts: [((Data) -> Request)] = []
        ) {
        self.type = type
        self.config = config
        self.callbacks = callbacks
        self.nexts = nexts
    }
    
    @discardableResult
    func next(_ next: @escaping ((Data) -> Request)) -> Request {
        nexts.insert(next, at: 0)
        return self
    }
    
    func toMethod() -> Methods.Basic {
        return Methods.Basic(self)
    }
}
