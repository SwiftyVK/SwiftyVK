public extension VKAPI {
    public enum Friends: Methods.API {
        case get(Parameters)
        case getOnline(Parameters)
        case getMutual(Parameters)
        case getRecent(Parameters)
        case getRequests(Parameters)
        case add(Parameters)
        case delete(Parameters)
        case getLists(Parameters)
        case addList(Parameters)
        case editList(Parameters)
        case deleteList(Parameters)
        case getAppUsers(Parameters)
        case getByPhones(Parameters)
        case deleteAllRequests(Parameters)
        case getSuggestions(Parameters)
        case areFriends(Parameters)
        case getAvailableForCall(Parameters)
        case search(Parameters)
    }
}
