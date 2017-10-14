extension APIScope {
    public enum NewsFeed: APIMethod {
        case addBan(Parameters)
        case deleteBan(Parameters)
        case deleteList(Parameters)
        case get(Parameters)
        case getBanned(Parameters)
        case getComments(Parameters)
        case getLists(Parameters)
        case getMentions(Parameters)
        case getRecommended(Parameters)
        case getSuggestedSources(Parameters)
        case ignoreItem(Parameters)
        case saveList(Parameters)
        case search(Parameters)
        case unignoreItem(Parameters)
        case unsubscribe(Parameters)
    }
}
