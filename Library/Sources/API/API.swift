public struct _VKAPI {
  /**
  A universal method for calling a sequence of other methods while saving and filtering interim results. More - https://vk.com/dev/execute
  - parameter code: Algorithm code in VKScript — a format similar to JavaSсript or ActionScript and assuming compatibility with ECMAScript.
  - returns: Request
  */
  public static func execute(_ code: String) -> Request {
    return Request(method: "execute", parameters: [VK.Arg.code : code])
  }
  
  
  
  /**
  Call stored functions on the VK servers
  
  - parameter method: method name
  - parameter parameters: method parameters
  - returns: Request
  */
  public static func remote(method: String, parameters: [VK.Arg : String] = [:]) -> Request {
    return Request(method: "execute.\(method)", parameters: parameters)
  }
  
  
  
  /**
  Formation of the request with the ability to manually specify the name of the method. Well, just in case :)
  - parameter method: method name
  - parameter parameters: method parameters
  - returns: Request
  */
  public static func custom(method: String, parameters: [VK.Arg : String] = [:]) -> Request {
    return Request(method: method, parameters: parameters)
  }
}
