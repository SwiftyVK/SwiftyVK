extension _VKAPI {
  ///Methods for working with photos. More - https://vk.com/dev/photos
  public struct Photos {
    
    
    
    ///Creates an empty photo album. More - https://vk.com/dev/photos.createAlbum
    public static func createAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.createAlbum", parameters: parameters)
    }
    
    
    
    ///Edits information about a photo album. More - https://vk.com/dev/photos.editAlbum
    public static func editAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.editAlbum", parameters: parameters)
    }
    
    
    
    ///Returns a list of a user's or community's photo albums. More - https://vk.com/dev/photos.getAlbums
    public static func getAlbums(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getAlbums", parameters: parameters)
    }
    
    
    
    ///Returns a list of a user's or community's photos. More - https://vk.com/dev/photos.get
    public static func get(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.get", parameters: parameters)
    }
    
    
    
    ///Returns the number of photo albums belonging to a user or community. More - https://vk.com/dev/photos.getAlbumsCount
    public static func getAlbumsCount(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getAlbumsCount", parameters: parameters)
    }
    
    
    
    
    ///Returns information about photos by their IDs. More - https://vk.com/dev/photos.getById
    public static func getById(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getById", parameters: parameters)
    }
    
    
    
    ///Returns the server address for photo upload. More - https://vk.com/dev/photos.getUploadServer
    public static func getUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getUploadServer", parameters: parameters)
    }
    
    
    
    ///Returns an upload server address for a profile or community photo. More - https://vk.com/dev/photos.getOwnerPhotoUploadServer
    public static func getOwnerPhotoUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getOwnerPhotoUploadServer", parameters: parameters)
    }
    
    
    
    ///Returns an upload link for chat cover pictures. More - https://vk.com/dev/photos.getChatUploadServer
    public static func getChatUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getChatUploadServer", parameters: parameters)
    }
    
    
    
    ///Saves a profile or community photo. More - https://vk.com/dev/photos.saveOwnerPhoto
    public static func saveOwnerPhoto(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.saveOwnerPhoto", parameters: parameters)
    }
    
    
    
    ///Saves a photo to a user's or community's wall after being uploaded, полученный методом photos.getWallUploadServer. More - https://vk.com/dev/photos.saveWallPhoto
    public static func saveWallPhoto(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.saveWallPhoto", parameters: parameters)
    }
    
    
    
    ///Returns the server address for photo upload onto a user's wall. More - https://vk.com/dev/photos.getWallUploadServer
    public static func getWallUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getWallUploadServer", parameters: parameters)
    }
    
    
    
    ///Returns the server address for photo upload in a private message for a user. More - http://vk.com/dev/photos.getMessagesUploadServer
    public static func getMessagesUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getMessagesUploadServer", parameters: parameters)
    }
    
    
    
    ///Saves a photo after being successfully uploaded. URL obtained with photos.getMessagesUploadServer method. More - http://vk.com/dev/photos.saveMessagesPhoto
    public static func saveMessagesPhoto(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.saveMessagesPhoto", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complaint about) a photo. More - https://vk.com/dev/photos.report
    public static func report(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.report", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complaint about) a comment on a photo. More - https://vk.com/dev/photos.reportComment
    public static func reportComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.reportComment", parameters: parameters)
    }
    
    
    
    ///Returns a list of photos. More - https://vk.com/dev/photos.search
    public static func search(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.search", parameters: parameters)
    }
    
    
    
    ///Saves photos after successful uploading. More - https://vk.com/dev/photos.save
    public static func save(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.save", parameters: parameters)
    }
    
    
    
    ///Allows to copy a photo to the "Saved photos" album. More - http://vk.com/dev/photos.copy
    public static func copy(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.copy", parameters: parameters)
    }
    
    
    
    ///Edits the caption of a photo. More - http://vk.com/dev/photos.
    public static func edit(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.edit", parameters: parameters)
    }
    
    
    
    ///Moves a photo from one album to another. More - http://vk.com/dev/photos.move
    public static func move(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.move", parameters: parameters)
    }
    
    
    
    ///Makes a photo into an album cover. More - https://vk.com/dev/photos.makeCover
    public static func makeCover(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.makeCover", parameters: parameters)
    }
    
    
    
    ///Reorders the album in the list of user albums. More - https://vk.com/dev/photos.reorderAlbums
    public static func reorderAlbums(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.reorderAlbums", parameters: parameters)
    }
    
    
    
    ///Reorders the photo in the list of photos of the user album. More - https://vk.com/dev/photos.reorderPhotos
    public static func reorderPhotos(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.reorderPhotos", parameters: parameters)
    }
    
    
    
    ///Returns a list of photos belonging to a user or community, in reverse chronological order. More - https://vk.com/dev/photos.getAll
    public static func getAll(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getAll", parameters: parameters)
    }
    
    
    
    ///Returns a list of photos in which a user is tagged. More - https://vk.com/dev/photos.getUserPhotos
    public static func getUserPhotos(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getUserPhotos", parameters: parameters)
    }
    
    
    
    ///Deletes a photo album belonging to the current user. More - https://vk.com/dev/photos.deleteAlbum
    public static func deleteAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.deleteAlbum", parameters: parameters)
    }
    
    
    
    ///Deletes a photo. More - https://vk.com/dev/photos.delete
    public static func delete(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.delete", parameters: parameters)
    }
    
    
    
    ///Restores a deleted photo. More - https://vk.com/dev/photos.restore
    public static func restore(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.restore", parameters: parameters)
    }
    
    
    
    ///Confirms a tag on a photo. More - https://vk.com/dev/photos.confirmTag
    public static func confirmTag(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.confirmTag", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a photo. More - https://vk.com/dev/photos.getComments
    public static func getComments(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getComments", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a specific photo album or all albums of the user sorted in reverse chronological order. More - https://vk.com/dev/photos.getAllComments
    public static func getAllComments(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getAllComments", parameters: parameters)
    }
    
    
    
    ///Adds a new comment on the photo. More - https://vk.com/dev/photos.createComment
    public static func createComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.createComment", parameters: parameters)
    }
    
    
    
    ///Deletes a comment on the photo. More - https://vk.com/dev/photos.deleteComment
    public static func deleteComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.deleteComment", parameters: parameters)
    }
    
    
    
    ///Restores a deleted comment on a photo. More - https://vk.com/dev/photos.restoreComment
    public static func restoreComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.restoreComment", parameters: parameters)
    }
    
    
    
    ///Edits a comment on a photo. More - https://vk.com/dev/photos.editComment
    public static func editComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.editComment", parameters: parameters)
    }
    
    
    
    ///Returns a list of tags on a photo. More - https://vk.com/dev/photos.getTags
    public static func getTags(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getTags", parameters: parameters)
    }
    
    
    
    ///Adds a tag on the photo. More - https://vk.com/dev/photos.putTag
    public static func putTag(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.putTag", parameters: parameters)
    }
    
    
    
    ///Removes a tag from a photo. More - https://vk.com/dev/photos.removeTag
    public static func removeTag(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.removeTag", parameters: parameters)
    }
    
    
    
    ///Returns a list of photos with tags that have not been viewed. More - https://vk.com/dev/photos.getNewTags
    public static func getNewTags(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getNewTags", parameters: parameters)
    }
    
    
    
    ///More - https://vk.com/dev/photos.getMarketAlbumUploadServer
    public static func getMarketAlbumUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getMarketAlbumUploadServer", parameters: parameters)
    }
    
    
    
    ///More - https://vk.com/dev/photos.saveMarketPhoto
    public static func saveMarketPhoto(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.saveMarketPhoto", parameters: parameters)
    }
    
    
    
    ///More - https://vk.com/dev/photos.saveMarketAlbumPhoto
    public static func saveMarketAlbumPhoto(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.saveMarketAlbumPhoto", parameters: parameters)
    }
    
    
    
    ///More - https://vk.com/dev/photos.getMarketUploadServer
    public static func getMarketUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "photos.getMarketUploadServer", parameters: parameters)
    }
  }
}
