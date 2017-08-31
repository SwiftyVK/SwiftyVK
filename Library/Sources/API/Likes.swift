public extension VKAPI {
    public enum Likes: Methods.API {
        case getList(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case isLiked(Parameters)
    }
}
