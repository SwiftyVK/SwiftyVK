public extension VK.Api {
    public enum Likes: Method {
        case getList(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case isLiked(Parameters)
    }
}
