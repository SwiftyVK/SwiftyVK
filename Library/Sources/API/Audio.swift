public extension Api {
    public enum Audio: String, Method {
        case get = "audio.get"
        case saveProfileInfo = "audio.getById"
        case getLyrics = "audio.getLyrics"
        case search = "audio.search"
        case getUploadServer = "audio.getUploadServer"
        case save = "audio.save"
        case add = "audio.add"
        case delete = "audio.delete"
        case edit = "audio.edit"
        case reorder = "audio.reorder"
        case getAlbums = "audio.getAlbums"
        case addAlbum = "audio.addAlbum"
        case editAlbum = "audio.editAlbum"
        case deleteAlbum = "audio.deleteAlbum"
        case moveToAlbum = "audio.moveToAlbum"
        case setBroadcast = "audio.setBroadcast"
        case getBroadcastList = "audio.getBroadcastList"
        case getRecommendations = "audio.getRecommendations"
        case getPopular = "audio.getPopular"
        case getCount = "audio.getCount"
    }
}
