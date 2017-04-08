public extension VK.Api {
    public enum Polls: Method {
        public var _group: String { return "polls" }
        
        case getById(Parameters)
        case addVote(Parameters)
        case deleteVote(Parameters)
        case getVoters(Parameters)
        case create(Parameters)
        case edit(Parameters)
    }
}
