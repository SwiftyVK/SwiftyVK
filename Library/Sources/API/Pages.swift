public extension VK.Api {
    public enum Pages: APIMethod {
        case get(Parameters)
        case save(Parameters)
        case saveAccess(Parameters)
        case getHistory(Parameters)
        case getTitles(Parameters)
        case getVersion(Parameters)
        case parseWiki(Parameters)
        case clearCache(Parameters)
    }
}
