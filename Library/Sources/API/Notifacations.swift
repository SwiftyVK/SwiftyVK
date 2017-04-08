public extension VK.Api {
    public enum Notifications: Method {
        public var _group: String { return "notifications" }
        
        case get(Parameters)
        case markAsViewed(Parameters)
    }
}
