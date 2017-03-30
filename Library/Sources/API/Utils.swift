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
  }
}
