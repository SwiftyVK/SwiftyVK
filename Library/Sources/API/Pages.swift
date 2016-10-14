extension _VKAPI {
  ///Methods for working with community pages. More - https://vk.com/dev/pages
  public struct Pages {
    
    
    
    ///Returns information about a wiki page. More - https://vk.com/dev/pages.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.get", parameters: parameters)
    }
    
    
    
    ///Saves the text of a wiki page. More - https://vk.com/dev/pages.save
    public static func save(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.save", parameters: parameters)
    }
    
    
    
    ///Saves modified read and edit access settings for a wiki page. More - https://vk.com/dev/pages.saveAccess
    public static func saveAccess(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.saveAccess", parameters: parameters)
    }
    
    
    
    ///Returns a list of all previous versions of a wiki page. More - https://vk.com/dev/pages.getHistory
    public static func getHistory(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.getHistory", parameters: parameters)
    }
    
    
    
    ///Returns a list of wiki pages in a group. More - https://vk.com/dev/pages.getTitles
    public static func getTitles(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.getTitles", parameters: parameters)
    }
    
    
    
    ///Returns the text of one of the previous versions of a wiki page. More - https://vk.com/dev/pages.getVersion
    public static func getVersion(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.getVersion", parameters: parameters)
    }
    
    
    
    ///Returns HTML representation of the wiki markup. More - https://vk.com/dev/pages.parseWiki
    public static func parseWiki(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.parseWiki", parameters: parameters)
    }
    
    
    
    ///Allows to clear the cache of particular external pages which may be attached to VK posts. More - https://vk.com/dev/pages.clearCache
    public static func clearCache(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "pages.clearCache", parameters: parameters)
    }
  }
}
