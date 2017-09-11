extension _VKAPI {
  ///Utilites. More - https://vk.com/dev/
  public struct Utils {



    ///Checks whether a link is blocked in VK. More - https://vk.com/dev/utils.checkLink
    public static func checkLink(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "utils.checkLink", parameters: parameters)
    }



    ///Detects a type of object (e.g., user, community, application) and its ID by screen name. More - https://vk.com/dev/utils.resolveScreenName
    public static func resolveScreenName(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "utils.resolveScreenName", parameters: parameters)
    }



    ///Returns the current time of the VK server. More - https://vk.com/dev/utils.getServerTime
    public static func getServerTime(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "utils.getServerTime", parameters: parameters)
    }
    
    
    
    ///Returns a list of user's shortened links. More - https://vk.com/dev/utils.getLastShortenedLinks
    public static func getLastShortenedLinks(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
        return RequestConfig(method: "utils.getLastShortenedLinks", parameters: parameters)
    }
    
    
    
    ///Allows to receive a link shortened via vk.cc. More - https://vk.com/dev/utils.getShortLink
    public static func getShortLink(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
        return RequestConfig(method: "utils.getShortLink", parameters: parameters)
    }
    
    
    
    ///Returns stats data for shortened link. More - https://vk.com/dev/utils.getLinkStats
    public static func getLinkStats(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
        return RequestConfig(method: "utils.getLinkStats", parameters: parameters)
    }
    
    
    
    ///Deletes shortened link from user's list. More - https://vk.com/dev/utils.deleteFromLastShortened
    public static func deleteFromLastShortened(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
        return RequestConfig(method: "utils.deleteFromLastShortened", parameters: parameters)
    }
  }
}
