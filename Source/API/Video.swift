extension _VKAPI {
  ///Methods for working with video. More - https://vk.com/dev/video
  public struct Video {
    
    
    
    ///Returns detailed information about videos. More - https://vk.com/dev/video.get
    public static func get(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.get", parameters: parameters)
    }
    
    
    
    ///Edits information about a video on a user or community page. More - https://vk.com/dev/video.edit
    public static func edit(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.edit", parameters: parameters)
    }
    
    
    
    ///Adds a video to a user or community page. More - https://vk.com/dev/video.add
    public static func add(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.add", parameters: parameters)
    }
    
    
    
    ///Returns a server address (required for upload) and video data. More - https://vk.com/dev/video.save
    public static func save(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.save", parameters: parameters)
    }
    
    
    
    ///Deletes a video from a user or community page. More - https://vk.com/dev/video.delete
    public static func delete(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.delete", parameters: parameters)
    }
    
    
    
    ///Restores a previously deleted video. More - https://vk.com/dev/video.restore
    public static func restore(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.restore", parameters: parameters)
    }
    
    
    
    ///Returns a list of videos under the set search criterion. More - https://vk.com/dev/video.search
    public static func search(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.search", parameters: parameters)
    }
    
    
    
    ///Returns list of videos in which the user is tagged. More - https://vk.com/dev/video.getUserVideos
    public static func getUserVideos(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getUserVideos", parameters: parameters)
    }
    
    
    
    ///Returns a list of video albums owned by a user or community. More - https://vk.com/dev/video.getAlbums
    public static func getAlbums(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getAlbums", parameters: parameters)
    }
    
    
    
    ///Returns a video album by ID. More - https://vk.com/dev/video.getAlbumById
    public static func getAlbumById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getAlbumById", parameters: parameters)
    }
    
    
    
    ///Creates an empty album for videos. More - https://vk.com/dev/video.addAlbum
    public static func addAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.addAlbum", parameters: parameters)
    }
    
    
    
    ///Edits the title of a video album. More - https://vk.com/dev/video.editAlbum
    public static func editAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.editAlbum", parameters: parameters)
    }
    
    
    
    ///Deletes a video album. More - https://vk.com/dev/video.deleteAlbum
    public static func deleteAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.deleteAlbum", parameters: parameters)
    }
    
    
    
    ///Reorders the album in the list of user video albums. More - https://vk.com/dev/video.moveToAlbum
    public static func moveToAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.moveToAlbum", parameters: parameters)
    }
    
    
    
    ///Add video to album. More - https://vk.com/dev/video.addToAlbum
    public static func addToAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.addToAlbum", parameters: parameters)
    }
    
    
    
    ///Remove video from album. More - https://vk.com/dev/video.removeFromAlbum
    public static func removeFromAlbum(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.removeFromAlbum", parameters: parameters)
    }
    
    
    
    ///Get list of video albums by video. More - https://vk.com/dev/video.getAlbumsByVideo
    public static func getAlbumsByVideo(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getAlbumsByVideo", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a video. More - https://vk.com/dev/video.getComments
    public static func getComments(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getComments", parameters: parameters)
    }
    
    
    
    ///Adds a new comment on a video. More - https://vk.com/dev/video.createComment
    public static func createComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.createComment", parameters: parameters)
    }
    
    
    
    ///Deletes a comment on a video. More - https://vk.com/dev/video.deleteComment
    public static func deleteComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.deleteComment", parameters: parameters)
    }
    
    
    
    ///Restores a previously deleted comment on a video. More - https://vk.com/dev/video.restoreComment
    public static func restoreComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.restoreComment", parameters: parameters)
    }
    
    
    
    ///Edits the text of a comment on a video. More - https://vk.com/dev/video.editComment
    public static func editComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.editComment", parameters: parameters)
    }
    
    
    
    ///Returns a list of tags on a video. More - https://vk.com/dev/video.getTags
    public static func getTags(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getTags", parameters: parameters)
    }
    
    
    
    ///Adds a tag on a video. More - https://vk.com/dev/video.putTag
    public static func putTag(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.putTag", parameters: parameters)
    }
    
    
    
    ///Removes a tag from a video. More - https://vk.com/dev/video.removeTag
    public static func removeTag(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.removeTag", parameters: parameters)
    }
    
    
    
    ///Returns a list of videos with tags that have not been viewed. More - https://vk.com/dev/video.getNewTags
    public static func getNewTags(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getNewTags", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complaint about) a video. More - https://vk.com/dev/video.report
    public static func report(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.report", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complaint about) a comment on a video. More - https://vk.com/dev/video.reportComment
    public static func reportComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.reportComment", parameters: parameters)
    }
    
    
    
    ///Returns video catalog
    public static func getCatalog(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getCatalog", parameters: parameters)
    }
    
    
    
    ///Returns video catalog block
    public static func getCatalogSection(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.getCatalogSection", parameters: parameters)
    }
    
    
    
    ///Hide video catalog section
    public static func hideCatalogSection(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "video.hideCatalogSection", parameters: parameters)
    }
  }
}

