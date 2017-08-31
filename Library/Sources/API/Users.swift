public extension VKAPI {
    public enum Users: Methods.API {
        case get(Parameters)
        case search(Parameters)
        case isAppUser(Parameters)
        case getSubscriptions(Parameters)
        case getFollowers(Parameters)
        case report(Parameters)
        case getNearby(Parameters)
    }
}
