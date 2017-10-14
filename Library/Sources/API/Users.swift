public extension PrivateVKAPI {
    public enum Users: APIMethod {
        case get(Parameters)
        case getFollowers(Parameters)
        case getNearby(Parameters)
        case getSubscriptions(Parameters)
        case isAppUser(Parameters)
        case report(Parameters)
        case search(Parameters)
    }
}
