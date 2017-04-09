public extension VK.Api {
    public enum Wall: Method {        
        case get(Parameters)
        case search(Parameters)
        case getById(Parameters)
        case post(Parameters)
        case repost(Parameters)
        case getReposts(Parameters)
        case edit(Parameters)
        case delete(Parameters)
        case restore(Parameters)
        case pin(Parameters)
        case unpin(Parameters)
        case getComments(Parameters)
        case addComment(Parameters)
        case editComment(Parameters)
        case deleteComment(Parameters)
        case restoreComment(Parameters)
        case reportPost(Parameters)
        case reportComment(Parameters)
    }
}
