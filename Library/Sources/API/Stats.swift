public extension PrivateVKAPI {
    public enum Stats: APIMethod {
        case get(Parameters)
        case getPostReach(Parameters)
        case trackVisitor(Parameters)
    }
}
