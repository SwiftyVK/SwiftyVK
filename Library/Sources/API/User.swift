public extension Api {
    public enum Users: String, Method {
        case get = "users.get"
        case search = "users.search"
        case isAppUser = "users.isAppUser"
        case getSubscriptions = "users.getSubscriptions"
        case getFollowers = "users.getFollowers"
        case report = "users.report"
        case getNearby = "users.getNearby"
    }
}
