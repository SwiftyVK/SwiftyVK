public extension Api {
    public enum Notes: String, Method {
        case get = "notes.get"
        case getById = "notes.getById"
        case getFriendsNotes = "notes.getFriendsNotes"
        case add = "notes.add"
        case edit = "notes.edit"
        case delete = "notes.delete"
        case getComments = "notes.getComments"
        case createComment = "notes.createComment"
        case editComment = "notes.editComment"
        case deleteComment = "notes.deleteComment"
        case restoreComment = "notes.restoreComment"
    }
}
