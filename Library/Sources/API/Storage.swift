extension _VKAPI {
  ///Methods for working with storage. More - https://vk.com/dev/storage
  public struct Storage {



    ///Returns a value of variable with the name set by key parameter. More - http://vk.com/dev/storage.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "storage.get", parameters: parameters)
    }


    ///Saves a value of variable with the name set by key parameter. More - https://vk.com/dev/storage.set
    public static func set(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "storage.set", parameters: parameters)
    }



    ///Returns the names of all variables. More - https://vk.com/dev/storage.getKeys
    public static func getKeys(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "storage.getKeys", parameters: parameters)
    }
  }
}
