public extension Api {
    public enum Likes: String, Method {
        case getList = "likes.getList"
        case add = "likes.add"
        case delete = "likes.delete"
        case isLiked = "likes.isLiked"
    }
}
