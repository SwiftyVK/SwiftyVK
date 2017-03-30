public extension Api {
    public enum Fave: String, Method {
        case getUsers = "fave.getUsers"
        case getPhotos = "fave.getPhotos"
        case getPosts = "fave.getPosts"
        case getVideos = "fave.getVideos"
        case getLinks = "fave.getLinks"
        case addUser = "fave.addUser"
        case removeUser = "fave.removeUser"
        case addGroup = "fave.addGroup"
        case removeGroup = "fave.removeGroup"
        case addLink = "fave.addLink"
        case removeLink = "fave.removeLink"
        case getMarketItems = "fave.getMarketItems"
    }
}
