public extension Api {
    public enum Notifications: String, Method {
        case get = "notifications.get"
        case markAsViewed = "notifications.markAsViewed"
    }
}
