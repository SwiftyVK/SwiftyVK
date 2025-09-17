extension APIScope {
    /// https://vk.ru/dev/stats
    public enum Stats: APIMethod {
        case get(Parameters)
        case getPostReach(Parameters)
        case trackVisitor(Parameters)
    }
}
