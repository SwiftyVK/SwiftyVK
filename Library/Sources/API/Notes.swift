public extension VK.Api {
    public enum Notes: Method {        
        case get(Parameters)
        case getById(Parameters)
        case getFriendsNotes(Parameters)
        case add(Parameters)
        case edit(Parameters)
        case delete(Parameters)
        case getComments(Parameters)
        case createComment(Parameters)
        case editComment(Parameters)
        case deleteComment(Parameters)
        case restoreComment(Parameters)
    }
}
