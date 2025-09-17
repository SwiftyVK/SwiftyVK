extension APIScope {
    /// https://vk.ru/dev/fave
    public enum Fave: APIMethod {
        case addGroup(Parameters)
        case addLink(Parameters)
        case addUser(Parameters)
        case getLinks(Parameters)
        case getMarketItems(Parameters)
        case getPhotos(Parameters)
        case getPosts(Parameters)
        case getUsers(Parameters)
        case getVideos(Parameters)
        case removeGroup(Parameters)
        case removeLink(Parameters)
        case removeUser(Parameters)
    }
}
