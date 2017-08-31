public extension VK.Api {
    public enum NewsFeed: APIMethod {
        case get(Parameters)
        case getRecommended(Parameters)
        case getComments(Parameters)
        case getMentions(Parameters)
        case getBanned(Parameters)
        case addBan(Parameters)
        case deleteBan(Parameters)
        case ignoreItem(Parameters)
        case unignoreItem(Parameters)
        case search(Parameters)
        case getLists(Parameters)
        case saveList(Parameters)
        case deleteList(Parameters)
        case unsubscribe(Parameters)
        case getSuggestedSources(Parameters)
    }
}
