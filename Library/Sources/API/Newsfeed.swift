extension _VKAPI {
  ///Methods for working with newsfeed. More - https://vk.com/dev/newsfeed
  public struct NewsFeed {

    ///Returns data required to show newsfeed for the current user. More - https://vk.com/dev/newsfeed.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.get", parameters: parameters)
    }

    ///Returns a list of newsfeeds recommended to the current user. More - https://vk.com/dev/newsfeed.getRecommended
    public static func getRecommended(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getRecommended", parameters: parameters)
    }

    ///Returns a list of comments in the current user's newsfeed. More - https://vk.com/dev/newsfeed.getComments
    public static func getComments(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getComments", parameters: parameters)
    }

    ///Returns a list of posts on user walls in which the current user is mentioned.. More - https://vk.com/dev/newsfeed.getMentions
    public static func getMentions(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getMentions", parameters: parameters)
    }

    ///Returns a list of users and communities banned from the current user's newsfeed. More - https://vk.com/dev/newsfeed.getBanned
    public static func getBanned(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getBanned", parameters: parameters)
    }

    ///Prevents news from specified users and communities from appearing in the current user's newsfeed. More - https://vk.com/dev/newsfeed.addBan
    public static func addBan(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.addBan", parameters: parameters)
    }

    ///Allows news from previously banned users and communities to be shown in the current user's newsfeed. 
    ///More - http://vk.com/dev/newsfeed.deleteBan
    public static func deleteBan(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.deleteBan", parameters: parameters)
    }

    ///Hides an item from the newsfeed. More - https://vk.com/dev/newsfeed.ignoreItem
    public static func ignoreItem(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.ignoreItem", parameters: parameters)
    }

    ///Returns a hidden item to the newsfeed. More - https://vk.com/dev/newsfeed.unignoreItem
    public static func unignoreItem(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.unignoreItem", parameters: parameters)
    }

    ///Returns search results by statuses. More - https://vk.com/dev/newsfeed.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.search", parameters: parameters)
    }

    ///Returns a list of newsfeeds followed by the current user. More - https://vk.com/dev/newsfeed.getLists
    public static func getLists(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getLists", parameters: parameters)
    }

    ///Creates and edits user newsfeed lists. More - https://vk.com/dev/newsfeed.saveList
    public static func saveList(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.saveList", parameters: parameters)
    }

    ///Allows the user to delete a list of news. More - https://vk.com/dev/newsfeed.deleteList
    public static func deleteList(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.deleteList", parameters: parameters)
    }

    ///Unsubscribe from the current user comments on a specified object. More - https://vk.com/dev/newsfeed.unsubscribe
    public static func unsubscribe(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.unsubscribe", parameters: parameters)
    }

    ///Returns and community members, for which the current user should subscribe. More - https://vk.com/dev/newsfeed.getSuggestedSources
    public static func getSuggestedSources(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "newsfeed.getSuggestedSources", parameters: parameters)
    }
  }
}
