public extension VK.Api {
    public enum Search: Method {
        public var _group: String { return "search" }
        
        case getHints(Parameters)
    }
}
