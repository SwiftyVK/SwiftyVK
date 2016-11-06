extension _VKAPI {
  ///Methods for working with statistic of pages and applications. More - https://vk.com/dev/stats
  public struct Stats {



    ///Returns statistics of a community or an application. More - https://vk.com/dev/stats.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "stats.get", parameters: parameters)
    }



    ///Adds information about the current session in the attendance statistics applications. More - https://vk.com/dev/stats.trackVisitor
    public static func trackVisitor(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "stats.trackVisitor", parameters: parameters)
    }



    ///Returns statistics for the records on the wall. More - https://vk.com/dev/stats.getPostReach
    public static func getPostReach(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "stats.getPostReach", parameters: parameters)
    }
  }
}
