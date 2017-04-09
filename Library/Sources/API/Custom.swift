public extension VK.Api {
    public struct Custom {
        public static func method(name: String) -> CustomMethod {
            return CustomMethod(method: name)
        }
        
        public static func remote(method: String) -> CustomMethod {
            return self.method(name: "execute.\(method)")
        }
        
        public static func execute(code: String, config: Config = .default) -> Request {
            return CustomMethod(method: "execute", parameters: [.code: code]).request(with: config)
        }
    }
}
