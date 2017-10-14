extension APIScope {
    public enum Likes: APIMethod {
        case add(Parameters)
        case delete(Parameters)
        case getList(Parameters)
        case isLiked(Parameters)
    }
}
