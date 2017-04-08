public extension VK.Api {
    public enum Fave: Method {
        public var _group: String { return "fave" }
        
        case getUsers(Parameters)
        case getPhotos(Parameters)
        case getPosts(Parameters)
        case getVideos(Parameters)
        case getLinks(Parameters)
        case addUser(Parameters)
        case removeUser(Parameters)
        case addGroup(Parameters)
        case removeGroup(Parameters)
        case addLink(Parameters)
        case removeLink(Parameters)
        case getMarketItems(Parameters)
    }
}
