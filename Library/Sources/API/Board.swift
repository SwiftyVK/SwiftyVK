extension APIScope {
    public enum Board: APIMethod {
        case addTopic(Parameters)
        case closeTopic(Parameters)
        case createComment(Parameters)
        case deleteComment(Parameters)
        case deleteTopic(Parameters)
        case editComment(Parameters)
        case editTopic(Parameters)
        case fixTopic(Parameters)
        case getComments(Parameters)
        case getTopics(Parameters)
        case openTopic(Parameters)
        case restoreComment(Parameters)
        case unfixTopic(Parameters)
    }
}
