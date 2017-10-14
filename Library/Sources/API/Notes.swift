public extension PrivateVKAPI {
    public enum Notes: APIMethod {
        case add(Parameters)
        case createComment(Parameters)
        case delete(Parameters)
        case deleteComment(Parameters)
        case edit(Parameters)
        case editComment(Parameters)
        case get(Parameters)
        case getById(Parameters)
        case getComments(Parameters)
        case restoreComment(Parameters)
    }
}
