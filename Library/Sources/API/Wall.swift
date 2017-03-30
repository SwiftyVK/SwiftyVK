public extension Api {
    public enum Wall: String, Method {
        case get = "video.get"
        case search = "wall.search"
        case getById = "wall.getById"
        case post = "wall.post"
        case repost = "wall.repost"
        case getReposts = "wall.getReposts"
        case edit = "wall.edit"
        case delete = "wall.delete"
        case restore = "wall.restore"
        case pin = "wall.pin"
        case unpin = "wall.unpin"
        case getComments = "wall.getComments"
        case addComment = "wall.addComment"
        case editComment = "wall.editComment"
        case deleteComment = "wall.deleteComment"
        case restoreComment = "wall.restoreComment"
        case reportPost = "wall.reportPost"
        case reportComment = "wall.reportComment"
    }
}
