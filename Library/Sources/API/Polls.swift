public extension VKAPI {
    public enum Polls: Methods.API {
        case getById(Parameters)
        case addVote(Parameters)
        case deleteVote(Parameters)
        case getVoters(Parameters)
        case create(Parameters)
        case edit(Parameters)
    }
}
