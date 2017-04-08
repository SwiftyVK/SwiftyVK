public extension VK.Api {
    public enum Likes: Method {
        public var _group: String { return "likes" }
        
        case getList(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case isLiked(Parameters)
    }
}
