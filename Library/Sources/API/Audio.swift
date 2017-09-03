extension _VKAPI {
  ///Methods for working with audio. More - https://vk.com/dev/audio
  public struct Audio {



    ///Returns a list of audio files of a user or community. More - https://vk.com/dev/audio.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.get", parameters: parameters)
    }



    ///Returns information about audio files by their IDs. More - https://vk.com/dev/audio.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getById", parameters: parameters)
    }



    ///Returns lyrics associated with an audio file. More - https://vk.com/dev/audio.getLyrics
    public static func getLyrics(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getLyrics", parameters: parameters)
    }



    ///Returns a list of audio files. More - https://vk.com/dev/audio.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.search", parameters: parameters)
    }



    ///Returns the server address to upload audio files. More - https://vk.com/dev/audio.getUploadServer
    public static func getUploadServer(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getUploadServer", parameters: parameters, handleProgress: false)
    }



    ///Saves audio files after successful uploading. More - https://vk.com/dev/audio.save
    public static func save(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.save", parameters: parameters, handleProgress: false)
    }



    ///Copies an audio file to a user page or community page. More - https://vk.com/dev/audio.add
    public static func add(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.add", parameters: parameters)
    }



    ///Deletes an audio file from a user page or community page. More - https://vk.com/dev/audio.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.delete", parameters: parameters)
    }



    ///Edits an audio file on a user or community page. More - https://vk.com/dev/audio.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.edit", parameters: parameters)
    }



    ///Reorders an audio file, placing it between other specified audio files. More - https://vk.com/dev/audio.reorder
    public static func reorder(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.reorder", parameters: parameters)
    }



    ///Restores a deleted audio file. More - https://vk.com/dev/audio.restore
    public static func restore(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.restore", parameters: parameters)
    }



    ///Returns a list of audio albums of a user or community. More - https://vk.com/dev/audio.getAlbums
    public static func getAlbums(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getAlbums", parameters: parameters)
    }



    ///Creates an empty audio album. More - https://vk.com/dev/audio.addAlbum
    public static func addAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.addAlbum", parameters: parameters)
    }



    ///Edits the title of an audio album. More - https://vk.com/dev/audio.editAlbum
    public static func editAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.editAlbum", parameters: parameters)
    }



    ///Deletes an audio album. More - https://vk.com/dev/audio.deleteAlbum
    public static func deleteAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.deleteAlbum", parameters: parameters)
    }



    ///Moves audio files to an album. More - https://vk.com/dev/audio.moveToAlbum
    public static func moveToAlbum(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.moveToAlbum", parameters: parameters)
    }



    ///Activates an audio broadcast to the status of a user or community. More - https://vk.com/dev/audio.setBroadcast
    public static func setBroadcast(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.setBroadcast", parameters: parameters)
    }



    ///Returns a list of the user's friends and communities that are broadcasting music in their statuses. 
    ///More - https://vk.com/dev/audio.getBroadcastList
    public static func getBroadcastList(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getBroadcastList", parameters: parameters)
    }



    ///Returns a list of suggested audio files based on a user's playlist or a particular audio file. 
    ///More - https://vk.com/dev/audio.getRecommendations
    public static func getRecommendations(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getRecommendations", parameters: parameters)
    }



    ///Returns a list of audio files from the "Popular". More - https://vk.com/dev/audio.getPopular
    public static func getPopular(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getPopular", parameters: parameters)
    }



    ///Returns the total number of audio files on a user or community page. More - https://vk.com/dev/audio.getCount
    public static func getCount(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "audio.getCount", parameters: parameters)
    }
  }
}
