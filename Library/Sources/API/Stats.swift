public extension VK.Api {
    public enum Stats: Method {
        case get(Parameters)
        case trackVisitor(Parameters)
        case getPostReach(Parameters)
    }
}
