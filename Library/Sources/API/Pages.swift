extension APIScope {
    /// https://vk.ru/dev/pages
    public enum Pages: APIMethod {
        case clearCache(Parameters)
        case get(Parameters)
        case getHistory(Parameters)
        case getTitles(Parameters)
        case getVersion(Parameters)
        case parseWiki(Parameters)
        case save(Parameters)
        case saveAccess(Parameters)
    }
}
