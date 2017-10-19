extension APIScope {
    /// https://vk.com/dev/notifications
    public enum Notifications: APIMethod {
        case get(Parameters)
        case markAsViewed(Parameters)
    }
}
