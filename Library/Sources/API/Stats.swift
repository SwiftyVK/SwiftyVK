extension APIScope {
    /// https://vk.com/dev/stats
    public enum Stats: APIMethod {
        case get(Parameters)
        case getPostReach(Parameters)
        case trackVisitor(Parameters)
    }
}
