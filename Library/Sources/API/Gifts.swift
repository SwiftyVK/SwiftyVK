extension _VKAPI {
  ///Methods for working with gifts. More - https://vk.com/dev/gifts
  public struct Gifts {
    
    
    
    ///Returns list of user gifts. More - https://vk.com/dev/gifts.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "get", parameters: parameters)
    }
  }
}
