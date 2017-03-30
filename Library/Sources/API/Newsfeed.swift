public extension Api {
    public enum NewsFeed: String, Method {
        case get = "newsfeed.get"
        case getRecommended = "newsfeed.getRecommended"
        case getComments = "newsfeed.getComments"
        case getMentions = "newsfeed.getMentions"
        case getBanned = "newsfeed.getBanned"
        case addBan = "newsfeed.addBan"
        case deleteBan = "newsfeed.deleteBan"
        case ignoreItem = "newsfeed.ignoreItem"
        case unignoreItem = "newsfeed.unignoreItem"
        case search = "newsfeed.search"
        case getLists = "newsfeed.getLists"
        case saveList = "newsfeed.saveList"
        case deleteList = "newsfeed.deleteList"
        case unsubscribe = "newsfeed.unsubscribe"
        case getSuggestedSources = "newsfeed.getSuggestedSources"
    }
}
