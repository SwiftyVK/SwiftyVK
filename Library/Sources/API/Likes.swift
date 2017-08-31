public extension VKAPI {
    public enum Likes: APIMethod {
        case getList(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case isLiked(Parameters)
    }
}
