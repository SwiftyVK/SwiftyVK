public extension VK.Api {
    public enum Status: Method {
        public var _group: String { return "status" }
        
        case get(Parameters)
        case set(Parameters)
    }
}
