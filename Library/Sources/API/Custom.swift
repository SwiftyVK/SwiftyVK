extension APIScope {
    /// Represents methods whick VK APi not contains directly
    public struct Custom {
        /// Alows to execute stored on VK server procedures
        public static func remote(method: String) -> CustomMethod {
            return self.method(name: "execute.\(method)")
        }
        
        /// Alows execute method which SwiftyVK does not support.
        /// If you use this, maybe report me about new VK API method?
        public static func method(name: String, parameters: Parameters = .empty) -> CustomMethod {
            return CustomMethod(method: name, parameters: parameters)
        }
        
        /// Allows execute https://vk.com/dev/execute
        public static func execute(code: String, config: Config = .default) -> CustomMethod {
            return CustomMethod(method: "execute", parameters: [.code: code])
        }
    }
}

// Do not use this class directly. Use VK.API.Custom
public final class CustomMethod: Method {
    let method: String
    let parameters: Parameters
    
    // Do not use this class directly. Use VK.API.Custom
    init(method: String, parameters: Parameters = .empty) {
        self.method = method
        self.parameters = parameters
    }

    public func toRequest() -> Request {
        return Request(type: .api(method: method, parameters: parameters))
    }
}
