import Foundation

public protocol APIMethod {}

public extension APIMethod {
    public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Methods.FailbaleProgressableConfigurable {
        let request = toRequest()
        request.callbacks.onSuccess = clousure
        return .init(request)
    }
    
    public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Methods.SuccessableProgressableConfigurable {
        let request = toRequest()
        request.callbacks.onError = clousure
        return .init(request)
    }
    
    func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Methods.SuccessableFailbaleConfigurable {
        let request = toRequest()
        request.callbacks.onProgress = clousure
        return .init(request)
    }
    
    public func configure(with config: Config) -> Methods.SuccessableFailbaleProgressable {
        let request = toRequest()
        request.config = config
        return .init(request)
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
