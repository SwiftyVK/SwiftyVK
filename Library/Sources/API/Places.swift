public extension VK.Api {
    public enum Places: Method {
        public var _group: String { return "places" }
        
        case add(Parameters)
        case getById(Parameters)
        case search(Parameters)
        case checkin(Parameters)
        case getCheckins(Parameters)
        case getTypes(Parameters)
    }
}
