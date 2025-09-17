extension APIScope {
    /// https://vk.ru/dev/likes
    public enum Likes: APIMethod {
        case add(Parameters)
        case delete(Parameters)
        case getList(Parameters)
        case isLiked(Parameters)
    }
}
