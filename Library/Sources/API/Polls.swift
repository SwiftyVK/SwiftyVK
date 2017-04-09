public extension VK.Api {
    public enum Polls: Method {        
        case getById(Parameters)
        case addVote(Parameters)
        case deleteVote(Parameters)
        case getVoters(Parameters)
        case create(Parameters)
        case edit(Parameters)
    }
}
