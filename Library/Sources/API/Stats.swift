public extension Api {
    public enum Stats: String, Method {
        case get = "stats.get"
        case trackVisitor = "stats.trackVisitor"
        case getPostReach = "stats.getPostReach"
    }
}
