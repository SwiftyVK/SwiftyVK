import Foundation

public protocol APIMethod: Method {}

extension APIMethod {
    public func toRequest() -> Request {
        Request(type: .api(method: method, parameters: parameters.toRaw()))
    }
}

extension APIMethod {
    var group: String {
        String(describing: type(of: self)).lowercased()
    }
    
    var method: String {
        "\(group).\(caseName(of: self))"
    }
    
    var parameters: Parameters {
        associatedValue(of: self) ?? .empty
    }
}
