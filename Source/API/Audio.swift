extension _VKAPI {
  ///Methods for working with audio. More - https://vk.com/dev/audio
  public struct Audio {
    
    
    
    ///Returns a list of audio files of a user or community. More - https://vk.com/dev/audio.get
    public static func get(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.get", parameters: parameters)
    }
    
    
    
    ///Returns information about audio files by their IDs. More - https://vk.com/dev/audio.getById
    public static func getById(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getById", parameters: parameters)
    }
    
    
    
    ///Returns lyrics associated with an audio file. More - https://vk.com/dev/audio.getLyrics
    public static func getLyrics(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getLyrics", parameters: parameters)
    }
    
    
    
    ///Returns a list of audio files. More - https://vk.com/dev/audio.search
    public static func search(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.search", parameters: parameters)
    }
    
    
    
    ///Returns the server address to upload audio files. More - https://vk.com/dev/audio.getUploadServer
    public static func getUploadServer(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getUploadServer", parameters: parameters)
    }
    
    
    
    ///Saves audio files after successful uploading. More - https://vk.com/dev/audio.save
    public static func save(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.save", parameters: parameters)
    }
    
    
    
    ///Copies an audio file to a user page or community page. More - https://vk.com/dev/audio.add
    public static func add(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.add", parameters: parameters)
    }
    
    
    
    ///Deletes an audio file from a user page or community page. More - https://vk.com/dev/audio.delete
    public static func delete(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.delete", parameters: parameters)
    }
    
    
    
    ///Edits an audio file on a user or community page. More - https://vk.com/dev/audio.edit
    public static func edit(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.edit", parameters: parameters)
    }
    
    
    
    ///Reorders an audio file, placing it between other specified audio files. More - https://vk.com/dev/audio.reorder
    public static func reorder(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.reorder", parameters: parameters)
    }
    
    
    
    ///Restores a deleted audio file. More - https://vk.com/dev/audio.restore
    public static func restore(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.restore", parameters: parameters)
    }
    
    
    
    ///Returns a list of audio albums of a user or community. More - https://vk.com/dev/audio.getAlbums
    public static func getAlbums(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getAlbums", parameters: parameters)
    }
    
    
    
    ///Creates an empty audio album. More - https://vk.com/dev/audio.addAlbum
    public static func addAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.addAlbum", parameters: parameters)
    }
    
    
    
    ///Edits the title of an audio album. More - https://vk.com/dev/audio.editAlbum
    public static func editAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.editAlbum", parameters: parameters)
    }
    
    
    
    ///Deletes an audio album. More - https://vk.com/dev/audio.deleteAlbum
    public static func deleteAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.deleteAlbum", parameters: parameters)
    }
    
    
    
    ///Moves audio files to an album. More - https://vk.com/dev/audio.moveToAlbum
    public static func moveToAlbum(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.moveToAlbum", parameters: parameters)
    }
    
    
    
    ///Activates an audio broadcast to the status of a user or community. More - https://vk.com/dev/audio.setBroadcast
    public static func setBroadcast(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.setBroadcast", parameters: parameters)
    }
    
    
    
    ///Returns a list of the user's friends and communities that are broadcasting music in their statuses. More - https://vk.com/dev/audio.getBroadcastList
    public static func getBroadcastList(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getBroadcastList", parameters: parameters)
    }
    
    
    
    ///Returns a list of suggested audio files based on a user's playlist or a particular audio file. More - https://vk.com/dev/audio.getRecommendations
    public static func getRecommendations(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getRecommendations", parameters: parameters)
    }
    
    
    
    ///Returns a list of audio files from the "Popular". More - https://vk.com/dev/audio.getPopular
    public static func getPopular(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getPopular", parameters: parameters)
    }
    
    
    
    ///Returns the total number of audio files on a user or community page. More - https://vk.com/dev/audio.getCount
    public static func getCount(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "audio.getCount", parameters: parameters)
    }
  }
}
