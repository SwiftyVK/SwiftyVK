import Foundation

public protocol APIMethod: Method {}

extension APIMethod {
    public func toRequest() -> Request {
        return Request(type: .api(method: method, parameters: parameters.toRaw()))
    }
}

extension APIMethod {
    var group: String {
        return String(describing: type(of: self)).lowercased()
    }
    
    var method: String {
        return "\(group).\(Mirror(reflecting: self).children.first?.label ?? String())"
    }
    
    var parameters: Parameters {
        return Mirror(reflecting: self).children.first?.value as? Parameters ?? .empty
    }
}
