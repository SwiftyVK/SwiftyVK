import Foundation

public protocol APIMethod: Method {}

public extension APIMethod {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> FailableConfigurableMethod {
        let request = toRequest()
        request.callbacks.onSuccess = clousure
        return FailableConfigurableMethod(request)
    }
    
    public func onError(_ clousure: @escaping (VKError) -> ()) -> SuccessableConfigurableMethod {
        let request = toRequest()
        request.callbacks.onError = clousure
        return SuccessableConfigurableMethod(request)
    }
    
    public func configure(with config: Config) -> SuccessableFailbaleMethod {
        let request = toRequest()
        request.config = config
        return SuccessableFailbaleMethod(request)
    }
    
    public func toRequest() -> Request {
        return Request(type: .api(method: method, parameters: parameters))
    }
}

private extension APIMethod {
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
