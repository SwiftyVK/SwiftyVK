public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: RequestCallbacks
    var next: Request?
    
    init(
        type: RequestType,
        config: Config = .default,
        callbacks: RequestCallbacks = .empty,
        next: Request? = nil
        ) {
        self.type = type
        self.config = config
        self.callbacks = callbacks
        self.next = next
    }
    
    func toMethod() -> Methods.Basic {
        return Methods.Basic(self)
    }
}
