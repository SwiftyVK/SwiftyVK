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
    public func configure(with config: Config) -> SuccessableFailbaleMethod {
        let request = toRequest()
        request.config = config
        return SuccessableFailbaleMethod(request)
    }
    
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
    
    public func toRequest() -> Request {
        return Request(type: .api(method: method, parameters: parameters))
    }
}
