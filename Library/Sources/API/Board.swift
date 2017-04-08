public extension VK.Api {
    public enum Board: Method {
        public var _group: String { return "board" }
        
        case getTopics(Parameters)
        case getComments(Parameters)
        case addTopic(Parameters)
        case addComment(Parameters)
        case deleteTopic(Parameters)
        case editTopic(Parameters)
        case editComment(Parameters)
        case restoreComment(Parameters)
        case deleteComment(Parameters)
        case openTopic(Parameters)
        case closeTopic(Parameters)
        case fixTopic(Parameters)
        case unfixTopic(Parameters)
    }
}
