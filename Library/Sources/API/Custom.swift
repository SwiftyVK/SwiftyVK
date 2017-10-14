extension PrivateVKAPI {
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
public final class CustomMethod: Method {
    let method: String
    let parameters: Parameters
    
    init(method: String, parameters: Parameters = .empty) {
        self.method = method
        self.parameters = parameters
    }

    public func toRequest() -> Request {
        return Request(type: .api(method: method, parameters: parameters))
    }
}
