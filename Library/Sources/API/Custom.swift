public extension VKAPI {
    public struct Custom {
        public static func remote(method: String) -> CustomMethod {
            return self.method(name: "execute.\(method)")
        }
        
        public static func method(name: String, parameters: Parameters = .empty) -> CustomMethod {
            return CustomMethod(method: name, parameters: parameters)
        }
        
        public static func execute(code: String, config: Config = .default) -> CustomMethod {
            return CustomMethod(method: "execute", parameters: [.code: code])
        }
    }
}

// Do not use this class directly. Use Api.Custom
public final class CustomMethod {
    let method: String
    let parameters: Parameters
    
    init(method: String, parameters: Parameters = .empty) {
        self.method = method
        self.parameters = parameters
    }
}

extension CustomMethod: Method {
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
    
    public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Methods.SuccessableFailbaleConfigurable {
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
