import Foundation

public protocol Method: MethodBase {}

public extension Method {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> FailableConfigurableMethod {
        var callbacks = Callbacks.empty
        callbacks.onSuccess = clousure
        return FailableConfigurableMethod(self, Config.default, callbacks)
    }
    
    public func onError(_ clousure: @escaping (VKError) -> ()) -> SuccessableConfigurableMethod {
        var callbacks = Callbacks.empty
        callbacks.onError = clousure
        return SuccessableConfigurableMethod(self, Config.default, callbacks)
    }
    
    public func configure(with config: Config) -> SuccessableFailbaleMethod {
        return SuccessableFailbaleMethod(self, config, Callbacks.empty)
    }
    
    @discardableResult
    public func send(in session: Session?) -> Task {
        return request().send(with: .empty, in: session)
    }
}

extension Method {
    func request(with config: Config = .default) -> Request {
        return Request(of: .api(method: method, parameters: parameters), config: config)
    }
}

private extension Method {
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
