public extension VK.Api {
    public enum Storage: Method {
        public var _group: String { return "storage" }
        
        case get(Parameters)
        case set(Parameters)
        case getKeys(Parameters)
    }
}
