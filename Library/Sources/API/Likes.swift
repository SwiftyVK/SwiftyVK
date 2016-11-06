extension _VKAPI {
  ///Methods for working with "Like". More - https://vk.com/dev/likes
  public struct Likes {



    ///Returns a list of IDs of users who added the specified object to their Likes list. More - https://vk.com/dev/likes.getList
    public static func getList(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "likes.getList", parameters: parameters)
    }



    ///Adds the specified object to the Likes list of the current user. More - https://vk.com/dev/likes.add
    public static func add(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "likes.add", parameters: parameters)
    }



    ///Deletes the specified object from the Likes list of the current user. More - https://vk.com/dev/likes.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "likes.delete", parameters: parameters)
    }



    ///Checks for the object in the Likes list of the specified user. More - https://vk.com/dev/likes.isLiked
    public static func isLiked(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "likes.isLiked", parameters: parameters)
    }
  }
}
