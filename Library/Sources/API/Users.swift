public extension VK.Api {
    public enum Users: Method {
        public var _group: String { return "users" }
        
        case get(Parameters)
        case search(Parameters)
        case isAppUser(Parameters)
        case getSubscriptions(Parameters)
        case getFollowers(Parameters)
        case report(Parameters)
        case getNearby(Parameters)
    }
}
