public extension PrivateVKAPI {
    public enum Polls: APIMethod {
        case getById(Parameters)
        case addVote(Parameters)
        case deleteVote(Parameters)
        case getVoters(Parameters)
        case create(Parameters)
        case edit(Parameters)
    }
}
