public extension VKAPI {
    public enum Stats: APIMethod {
        case get(Parameters)
        case trackVisitor(Parameters)
        case getPostReach(Parameters)
    }
}
