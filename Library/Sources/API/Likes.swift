public extension VK.Api {
    public enum Likes: APIMethod {
        case getList(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case isLiked(Parameters)
    }
}
