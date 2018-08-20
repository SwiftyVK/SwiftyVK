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
        return "\(group).\(caseName(of: self))"
    }
    
    var parameters: Parameters {
        return associatedValue(of: self) ?? .empty
    }
}
