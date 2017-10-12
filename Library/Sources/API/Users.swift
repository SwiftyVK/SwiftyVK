public extension PrivateVKAPI {
    public enum Users: APIMethod {
        case get(Parameters)
        case search(Parameters)
        case isAppUser(Parameters)
        case getSubscriptions(Parameters)
        case getFollowers(Parameters)
        case report(Parameters)
        case getNearby(Parameters)
    }
}
