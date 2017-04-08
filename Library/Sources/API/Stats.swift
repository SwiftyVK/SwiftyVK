public extension VK.Api {
    public enum Stats: Method {
        public var _group: String { return "stats" }
        
        case get(Parameters)
        case trackVisitor(Parameters)
        case getPostReach(Parameters)
    }
}
