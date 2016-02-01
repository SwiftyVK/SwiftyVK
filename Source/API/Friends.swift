extension _VKAPI {
  ///Methods for working with friends. More - https://vk.com/dev/friends
  public struct Friends {
    
    
    
    ///Returns a list of user IDs or detailed information about a user's friends. More - https://vk.com/dev/friends.get
    public static func get(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.get", parameters: parameters)
    }
    
    
    
    ///Returns a list of user IDs of a user's friends who are online. More - https://vk.com/dev/friends.getOnline
    public static func getOnline(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getOnline", parameters: parameters)
    }
    
    
    
    ///Returns a list of user IDs of the mutual friends of two users. More - https://vk.com/dev/friends.getMutual
    public static func getMutual(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getMutual", parameters: parameters)
    }
    
    
    
    ///Returns a list of user IDs of the current user's recently added friends. More - https://vk.com/dev/friends.getRecent
    public static func getRecent(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getRecent", parameters: parameters)
    }
    
    
    
    ///Returns information about the current user's incoming and outgoing friend requests. More - https://vk.com/dev/friends.getRequests
    public static func getRequests(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getRequests", parameters: parameters)
    }
    
    
    
    ///Approves or creates a friend request. More - https://vk.com/dev/friends.add
    public static func add(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.add", parameters: parameters)
    }
    
    
    
    ///Edits the friend lists of the selected user. More - https://vk.com/dev/friends.edit
    public static func edit(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.edit", parameters: parameters)
    }
    
    
    
    ///Declines a friend request or deletes a user from the current user's friend list. More - https://vk.com/dev/friends.delete
    public static func delete(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.delete", parameters: parameters)
    }
    
    
    
    ///Returns a list of the current user's friend lists. More - https://vk.com/dev/friends.getLists
    public static func getLists(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getLists", parameters: parameters)
    }
    
    
    
    ///Creates a new friend list for the current user. More - https://vk.com/dev/friends.addList
    public static func addList(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.addList", parameters: parameters)
    }
    
    
    
    ///Edits a friend list of the current user. More - https://vk.com/dev/friends.editList
    public static func editList(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.editList", parameters: parameters)
    }
    
    
    
    ///Deletes a friend list of the current user. More - https://vk.com/dev/friends.deleteList
    public static func deleteList(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.deleteListr", parameters: parameters)
    }
    
    
    
    ///Returns a list of IDs of the current user's friends who installed the application. More - https://vk.com/dev/friends.getAppUsers
    public static func getAppUsers(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getAppUsers", parameters: parameters)
    }
    
    
    
    ///Returns a list of the current user's friends whose phone numbers, validated or specified in a profile, are in a given list. More - https://vk.com/dev/friends.getByPhones
    public static func getByPhones(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getByPhones", parameters: parameters)
    }
    
    
    
    ///Marks all incoming friend requests as viewed. More - https://vk.com/dev/friends.deleteAllRequests
    public static func deleteAllRequests(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.deleteAllRequests", parameters: parameters)
    }
    
    
    
    ///Returns a list of profiles of users whom the current user may know. More - https://vk.com/dev/friends.getSuggestions
    public static func getSuggestions(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getSuggestions", parameters: parameters)
    }
    
    
    
    ///Checks the current user's friendship status with other specified users. More - https://vk.com/dev/friends.areFriends
    public static func areFriends(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.areFriends", parameters: parameters)
    }
    
    
    
    ///Return list of avialable for call users. More - https://vk.com/dev/friends.getAvailableForCall
    public static func getAvailableForCall(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.getAvailableForCall", parameters: parameters)
    }
    
    
    
    ///Allows search friends of user. More - https://vk.com/dev/friends.search
    public static func search(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "friends.search", parameters: parameters)
    }
  }
}
