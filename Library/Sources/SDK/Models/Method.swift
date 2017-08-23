public protocol Method {}

public extension Method {
    
    public func request(with config: Config = .default) -> Request {
        return Request(of: .api(method: method, parameters: parameters), config: config)
    }
    
    @discardableResult
    public func send(with callbacks: Callbacks, in session: Session? = nil) -> Task {
        return request().send(with: callbacks, in: session)
    }
    
    private var group: String {
        return String(describing: type(of: self)).lowercased()
    }
    
    private var method: String {
        return "\(group).\(Mirror(reflecting: self).children.first?.label ?? String())"
    }
    
    private var parameters: Parameters {
        return Mirror(reflecting: self).children.first?.value as? Parameters ?? .empty
    }
}
