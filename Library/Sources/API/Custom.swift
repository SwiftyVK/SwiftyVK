public extension VK.Api {
    public struct Custom {
        public static func methodWith(name: String) -> Method {
            return CustomMethod(name: name)
        }
        
        public static func remoteCall(method: String) -> Method {
            return methodWith(name: "execute.\(method)")
        }
        
        public static func execute(code: String, config: Config = .default) -> Request {
            return CustomMethod(name: "execute", parameters: [.code: code]).request(with: config)
        }
    }
}

private class CustomMethod: Method {
    public var _group = "custom"
    public let name: String
    public let parameters: Parameters
    
    init(name: String, parameters: Parameters = .empty) {
        self.name = name
        self.parameters = parameters
    }
}
