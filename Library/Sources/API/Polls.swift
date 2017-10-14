extension APIScope {
    public enum Polls: APIMethod {
        case addVote(Parameters)
        case create(Parameters)
        case deleteVote(Parameters)
        case edit(Parameters)
        case getById(Parameters)
        case getVoters(Parameters)
    }
}
