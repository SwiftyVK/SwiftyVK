extension APIScope {
    /// https://vk.com/dev/likes
    public enum Likes: APIMethod {
        case add(Parameters)
        case delete(Parameters)
        case getList(Parameters)
        case isLiked(Parameters)
    }
}
