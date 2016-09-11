extension _VKAPI {
  ///Methods for working with users. More - https://vk.com/dev/users
  public struct Users {
    
    
    
    ///Returns detailed information on users. More - https://vk.com/dev/users.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.get", parameters: parameters)
    }
    
    
    
    ///Returns a list of users matching the search criteria. More - https://vk.com/dev/users.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.search", parameters: parameters)
    }
    
    
    
    ///Returns information whether a user installed the application. More - https://vk.com/dev/users.isAppUser
    public static func isAppUser(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.isAppUser", parameters: parameters)
    }
    
    
    
    ///Returns a list of IDs of users and communities followed by the user. More - https://vk.com/dev/users.getSubscriptions
    public static func getSubscriptions(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.getSubscriptions", parameters: parameters)
    }
    
    
    ///Returns a list of IDs of followers of the user in question, sorted by date added, most recent first. More - https://vk.com/dev/users.getFollowers
    public static func getFollowers(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.getFollowers", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complain about) a user. More - https://vk.com/dev/users.report
    public static func report(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.report", parameters: parameters)
    }
    
    
    
    ///Indexes user's current location and returns a list of users who are in the vicinity. More - https://vk.com/dev/users.getNearby
    public static func getNearby(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "users.getNearby", parameters: parameters)
    }
  }
}
