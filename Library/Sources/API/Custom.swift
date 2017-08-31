public extension VKAPI {
    public struct Custom {
        public static func method(name: String, parameters: Parameters = .empty) -> CustomMethod {
            return CustomMethod(method: name, parameters: parameters)
        }
        
        public static func remote(method: String) -> CustomMethod {
            return self.method(name: "execute.\(method)")
        }
        
        public static func execute(code: String, config: Config = .default) -> Request {
            return CustomMethod(method: "execute", parameters: [.code: code]).request(with: config)
        }
    }
}

// Do not use this class directly. Use Api.Custom
public class CustomMethod {
    public let method: String
    public let parameters: Parameters
    
    init(method: String, parameters: Parameters = .empty) {
        self.method = method
        self.parameters = parameters
    }
    
    func request(with config: Config = .default) -> Request {
        return Request(type: .api(method: method, parameters: parameters))
    }
    
}
