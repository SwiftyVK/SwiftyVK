extension APIScope {
    public enum Notifications: APIMethod {
        case get(Parameters)
        case markAsViewed(Parameters)
    }
}
