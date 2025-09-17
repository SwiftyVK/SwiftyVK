extension APIScope {
    /// https://vk.ru/dev/notifications
    public enum Notifications: APIMethod {
        case get(Parameters)
        case markAsViewed(Parameters)
    }
}
