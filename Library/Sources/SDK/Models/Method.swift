public protocol Method {
    var _group: String { get }
}

public extension Method {
    
    public func request(with config: Config = .default) -> Request {
        return Request(rawRequest: .api(method: method, parameters: parameters), config: config)
    }
    
    @discardableResult
    public func send(with callbacks: Callbacks) -> Task {
        return request().send(with: callbacks)
    }
    
    var method: String {
        return "\(_group).\(Mirror(reflecting: self).children.first?.label ?? String())"
    }
    
    var parameters: Parameters {
        return Mirror(reflecting: self).children.first?.value as? Parameters ?? .empty
    }
}
