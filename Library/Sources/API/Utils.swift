public extension VK.Api {
    public enum Utils: Method {
        public var _group: String { return "utils" }
        
        case checkLink(Parameters)
        case resolveScreenName(Parameters)
        case getServerTime(Parameters)
    }
}
