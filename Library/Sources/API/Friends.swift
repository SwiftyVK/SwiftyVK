extension APIScope {
    /// https://vk.com/dev/friends
    public enum Friends: APIMethod {
        case add(Parameters)
        case addList(Parameters)
        case areFriends(Parameters)
        case delete(Parameters)
        case deleteAllRequests(Parameters)
        case deleteList(Parameters)
        case edit(Parameters)
        case editList(Parameters)
        case get(Parameters)
        case getAppUsers(Parameters)
        case getByPhones(Parameters)
        case getLists(Parameters)
        case getMutual(Parameters)
        case getOnline(Parameters)
        case getRecent(Parameters)
        case getRequests(Parameters)
        case getSuggestions(Parameters)
        case search(Parameters)
    }
}
