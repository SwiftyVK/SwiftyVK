public class SendableMethod: Sendable {
    let method: Method
    var callbacks: Callbacks
    let config: Config
    
    init(_ method: Method, _ config: Config, _ callbacks: Callbacks) {
        self.method = method
        self.callbacks = callbacks
        self.config = config
    }
    
    public final func send(in session: Session?) -> Task {
        return method.request(with: config).send(with: callbacks, in: session)
    }
}
