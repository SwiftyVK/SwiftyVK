extension APIScope {
    /// https://vk.ru/dev/docs
    public enum Docs: APIMethod {
        case add(Parameters)
        case delete(Parameters)
        case edit(Parameters)
        case get(Parameters)
        case getById(Parameters)
        case getMessagesUploadServer(Parameters)
        case getTypes(Parameters)
        case getUploadServer(Parameters)
        case getWallUploadServer(Parameters)
        case save(Parameters)
        case search(Parameters)
    }
}
