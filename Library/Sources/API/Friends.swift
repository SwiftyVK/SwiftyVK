public extension Api {
    public enum Friends: String, Method {
        case get = "friends.get"
        case getOnline = "friends.getOnline"
        case getMutual = "friends.getMutual"
        case getRecent = "friends.getRecent"
        case getRequests = "friends.getRequests"
        case add = "friends.add"
        case delete = "friends.delete"
        case getLists = "friends.getLists"
        case addList = "friends.addList"
        case editList = "friends.editList"
        case deleteList = "friends.deleteList"
        case getAppUsers = "friends.getAppUsers"
        case getByPhones = "friends.getByPhones"
        case deleteAllRequests = "friends.deleteAllRequests"
        case getSuggestions = "friends.getSuggestions"
        case areFriends = "friends.areFriends"
        case getAvailableForCall = "friends.getAvailableForCall"
        case search = "friends.search"
    }
}
