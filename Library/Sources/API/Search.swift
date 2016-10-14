extension _VKAPI {
  ///Methods for working with quick search. More - https://vk.com/dev/search
  public struct Search {
    
    
    
    ///Allows the programmer to do a quick search for any substring. More - https://vk.com/dev/search.getHints
    public static func getHints(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "search.getHints", parameters: parameters)
    }
  }
}
