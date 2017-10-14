public extension PrivateVKAPI {
    public enum Wall: APIMethod {
        case createComment(Parameters)
        case delete(Parameters)
        case deleteComment(Parameters)
        case edit(Parameters)
        case editAdsStealth(Parameters)
        case editComment(Parameters)
        case get(Parameters)
        case getById(Parameters)
        case getComments(Parameters)
        case getReposts(Parameters)
        case pin(Parameters)
        case post(Parameters)
        case postAdsStealth(Parameters)
        case reportComment(Parameters)
        case reportPost(Parameters)
        case repost(Parameters)
        case restore(Parameters)
        case restoreComment(Parameters)
        case search(Parameters)
        case unpin(Parameters)
    }
}
