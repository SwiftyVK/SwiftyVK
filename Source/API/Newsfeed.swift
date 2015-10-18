extension _VKAPI {
  ///Methods for working with newsfeed. More - https://vk.com/dev/newsfeed
  public struct NewsFeed {
    
    
    
    ///Returns data required to show newsfeed for the current user. More - https://vk.com/dev/newsfeed.get
    public static func get(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.get", parameters: parameters)
    }
    
    
    
    ///Returns a list of newsfeeds recommended to the current user. More - https://vk.com/dev/newsfeed.getRecommended
    public static func getRecommended(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getRecommended", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments in the current user's newsfeed. More - https://vk.com/dev/newsfeed.getComments
    public static func getComments(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getComments", parameters: parameters)
    }
    
    
    
    ///Returns a list of posts on user walls in which the current user is mentioned.. More - https://vk.com/dev/newsfeed.getMentions
    public static func getMentions(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getMentions", parameters: parameters)
    }
    
    
    
    ///Returns a list of users and communities banned from the current user's newsfeed. More - https://vk.com/dev/newsfeed.getBanned
    public static func getBanned(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getBanned", parameters: parameters)
    }
    
    
    
    ///Prevents news from specified users and communities from appearing in the current user's newsfeed. More - https://vk.com/dev/newsfeed.addBan
    public static func addBan(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.addBan", parameters: parameters)
    }
    
    
    
    ///Allows news from previously banned users and communities to be shown in the current user's newsfeed. More - http://vk.com/dev/newsfeed.deleteBan
    public static func deleteBan(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.deleteBan", parameters: parameters)
    }
    
    
    
    ///Hides an item from the newsfeed. More - https://vk.com/dev/newsfeed.ignoreItem
    public static func ignoreItem(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.ignoreItem", parameters: parameters)
    }
    
    
    
    ///Returns a hidden item to the newsfeed. More - https://vk.com/dev/newsfeed.unignoreItem
    public static func unignoreItem(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.unignoreItem", parameters: parameters)
    }
    
    
    
    ///Returns search results by statuses. More - https://vk.com/dev/newsfeed.search
    public static func search(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.search", parameters: parameters)
    }
    
    
    
    ///Returns a list of newsfeeds followed by the current user. More - https://vk.com/dev/newsfeed.getLists
    public static func getLists(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getLists", parameters: parameters)
    }
    
    
    
    ///Creates and edits user newsfeed lists. More - https://vk.com/dev/newsfeed.saveList
    public static func saveList(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.saveList", parameters: parameters)
    }
    
    
    
    ///Allows the user to delete a list of news. More - https://vk.com/dev/newsfeed.deleteList
    public static func deleteList(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.deleteList", parameters: parameters)
    }
    
    
    
    ///Unsubscribe from the current user comments on a specified object. More - https://vk.com/dev/newsfeed.unsubscribe
    public static func unsubscribe(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.unsubscribe", parameters: parameters)
    }
    
    
    
    ///Returns and community members, for which the current user should subscribe. More - https://vk.com/dev/newsfeed.getSuggestedSources
    public static func getSuggestedSources(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "newsfeed.getSuggestedSources", parameters: parameters)
    }
  }
}
