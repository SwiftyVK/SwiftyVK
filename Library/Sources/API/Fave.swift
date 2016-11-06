extension _VKAPI {
  ///Methods for working with bookmarks. More - https://vk.com/dev/fave
  public struct Fave {



    ///Returns a list of users whom the current user has bookmarked. More - https://vk.com/dev/fave.getUsers
    public static func getUsers(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getUsers", parameters: parameters)
    }



    ///Returns a list of photos that the current user has liked. More - https://vk.com/dev/fave.getPhotos
    public static func getPhotos(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getPhotos", parameters: parameters)
    }



    ///Returns a list of wall posts that the current user has liked. More - https://vk.com/dev/fave.getPosts
    public static func getPosts(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getPosts", parameters: parameters)
    }



    ///Returns a list of videos that the current user has liked. More - https://vk.com/dev/fave.getVideos
    public static func getVideos(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getVideos", parameters: parameters)
    }



    ///Returns a list of links that the current user has bookmarked. More - https://vk.com/dev/fave.getLinks
    public static func getLinks(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getLinks", parameters: parameters)
    }



    ///Add user to the bookmarks. More - https://vk.com/dev/fave.addUser
    public static func addUser(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.addUser", parameters: parameters)
    }



    ///Remove user to the bookmarks. More - https://vk.com/dev/fave.removeUser
    public static func removeUser(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.removeUser", parameters: parameters)
    }



    ///Add group to the bookmarks. More - https://vk.com/dev/fave.addGroup
    public static func addGroup(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.addGroup", parameters: parameters)
    }



    ///Remove group to the bookmarks. More - https://vk.com/dev/fave.removeGroup
    public static func removeGroup(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.removeGroup", parameters: parameters)
    }



    ///Add link to the bookmarks. More - https://vk.com/dev/fave.addLink
    public static func addLink(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.addLink", parameters: parameters)
    }



    ///Remove link to the bookmarks. More - https://vk.com/dev/fave.removeLink
    public static func removeLink(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.removeLink", parameters: parameters)
    }



    ///Remove link to the bookmarks. More - https://vk.com/dev/fave.getMarketItems
    public static func getMarketItems(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "fave.getMarketItems", parameters: parameters)
    }
  }
}
