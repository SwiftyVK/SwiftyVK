extension _VKAPI {
  ///Methods for working with bookmarks. More - https://vk.com/dev/fave
  public struct Fave {
    
    
    
    ///Returns a list of users whom the current user has bookmarked. More - https://vk.com/dev/fave.getUsers
    public static func getUsers(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getUsers", parameters: parameters)
    }
    
    
    
    ///Returns a list of photos that the current user has liked. More - https://vk.com/dev/fave.getPhotos
    public static func getPhotos(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getPhotos", parameters: parameters)
    }
    
    
    
    ///Returns a list of wall posts that the current user has liked. More - https://vk.com/dev/fave.getPosts
    public static func getPosts(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getPosts", parameters: parameters)
    }
    
    
    
    ///Returns a list of videos that the current user has liked. More - https://vk.com/dev/fave.getVideos
    public static func getVideos(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getVideos", parameters: parameters)
    }
    
    
    
    ///Returns a list of links that the current user has bookmarked. More - https://vk.com/dev/fave.getLinks
    public static func getLinks(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getLinks", parameters: parameters)
    }
    
    
    
    ///Add user to the bookmarks. More - https://vk.com/dev/fave.addUser
    public static func addUser(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.addUser", parameters: parameters)
    }
    
    
    
    ///Remove user to the bookmarks. More - https://vk.com/dev/fave.removeUser
    public static func removeUser(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.removeUser", parameters: parameters)
    }
    
    
    
    ///Add group to the bookmarks. More - https://vk.com/dev/fave.addGroup
    public static func addGroup(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.addGroup", parameters: parameters)
    }
    
    
    
    ///Remove group to the bookmarks. More - https://vk.com/dev/fave.removeGroup
    public static func removeGroup(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.removeGroup", parameters: parameters)
    }
    
    
    
    ///Add link to the bookmarks. More - https://vk.com/dev/fave.addLink
    public static func addLink(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.addLink", parameters: parameters)
    }
    
    
    
    ///Remove link to the bookmarks. More - https://vk.com/dev/fave.removeLink
    public static func removeLink(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.removeLink", parameters: parameters)
    }
    
    
    
    ///Remove link to the bookmarks. More - https://vk.com/dev/fave.getMarketItems
    public static func getMarketItems(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "fave.getMarketItems", parameters: parameters)
    }
  }
}
