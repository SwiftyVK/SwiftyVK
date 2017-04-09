public extension VK.Api {
    public enum Users: Method {        
        case get(Parameters)
        case search(Parameters)
        case isAppUser(Parameters)
        case getSubscriptions(Parameters)
        case getFollowers(Parameters)
        case report(Parameters)
        case getNearby(Parameters)
    }
}
