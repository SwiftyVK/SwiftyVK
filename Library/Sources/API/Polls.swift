public extension Api {
    public enum Polls: String, Method {
        case getById = "polls.getById"
        case addVote = "polls.addVote"
        case deleteVote = "polls.deleteVote"
        case getVoters = "polls.getVoters"
        case create = "polls.create"
        case edit = "polls.edit"
    }
}
