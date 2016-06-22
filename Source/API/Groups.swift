extension _VKAPI {
  ///Methods for working with groups. More - https://vk.com/dev/groups
  public struct Groups {
    
    
    
    ///Returns information specifying whether a user is a member of a community. More - https://vk.com/dev/users.get
    public static func isMember(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.isMember", parameters: parameters)
    }
    
    
    
    ///Returns information about communities by their IDs. More - https://vk.com/dev/groups.isMember
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getById", parameters: parameters)
    }
    
    
    
    ///Returns a list of the communities to which a user belongs. More - https://vk.com/dev/groups.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.get", parameters: parameters)
    }
    
    
    
    ///Returns a list of community members. More - https://vk.com/dev/groups.getMembers
    public static func getMembers(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getMembers", parameters: parameters)
    }
    
    
    
    ///With this method you can join the group or public page, and also confirm your participation in an event. More - https://vk.com/dev/groups.join
    public static func join(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.join", parameters: parameters)
    }
    
    
    
    ///With this method you can leave a group, public page, or event. More - https://vk.com/dev/groups.leave
    public static func leave(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.leave", parameters: parameters)
    }
    
    
    
    ///Searches for communities by substring. More - https://vk.com/dev/groups.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.search", parameters: parameters)
    }
    
    
    
    ///Returns a list of invitations to join communities and events. More - https://vk.com/dev/groups.getInvites
    public static func getInvites(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getInvites", parameters: parameters)
    }
    
    
    
    
    ///Returns invited user. More - https://vk.com/dev/groups.getInvitedUsers
    public static func getInvitedUsers(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getInvitedUsers", parameters: parameters)
    }
    
    
    
    ///Adds a user to a community blacklist. More - https://vk.com/dev/groups.banUser
    public static func banUser(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.banUser", parameters: parameters)
    }
    
    
    
    ///Deletes a user from a community blacklist. More - https://vk.com/dev/groups.unbanUser
    public static func unbanUser(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.unbanUser", parameters: parameters)
    }
    
    
    
    ///Returns a list of users on a community blacklist. More - https://vk.com/dev/groups.getBanned
    public static func getBanned(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getBanned", parameters: parameters)
    }

    
    
    ///Create new community. More - https://vk.com/dev/groups.create
    public static func create(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.create", parameters: parameters)
    }
    
    
    
    ///Edit community info. More - https://vk.com/dev/groups.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.edit", parameters: parameters)
    }
    
    
    
    ///Edit community places. More - https://vk.com/dev/groups.editPlace
    public static func editPlace(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.editPlace", parameters: parameters)
    }
    
    
    
    ///Returns data necessary to display the data editing community. More - https://vk.com/dev/groups.getSettings
    public static func getSettings(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getSettings", parameters: parameters)
    }
    
    
    
    ///Returns a list requests for entry into the community. More - https://vk.com/dev/groups.getRequests
    public static func getRequests(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getRequests", parameters: parameters)
    }
    
    
    
    ///Allows you to assign/demote a manager in the community, or to change the level of its powers. More - https://vk.com/dev/groups.editManager
    public static func editManager(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.editManager", parameters: parameters)
    }
    
    
    
    ///Allows invite users to community. More - https://vk.com/dev/groups.invite
    public static func invite(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.invite", parameters: parameters)
    }
    
    
    
    ///Allows add links to community. More - https://vk.com/dev/groups.addLink
    public static func addLink(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.addLink", parameters: parameters)
    }
    
    
    
    ///Allows remove links to community. More - https://vk.com/dev/groups.deleteLink
    public static func deleteLink(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.deleteLink", parameters: parameters)
    }
    
    
    
    ///Allows edit links to community. More - https://vk.com/dev/groups.editLink
    public static func editLink(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.editLink", parameters: parameters)
    }
    
    
    
    ///Allows you to change the location of the reference list. More - https://vk.com/dev/groups.reorderLink
    public static func reorderLink(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.reorderLink", parameters: parameters)
    }
    
    
    
    ///Allows edit user to community. More - https://vk.com/dev/groups.removeUser
    public static func removeUser(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.removeUser", parameters: parameters)
    }
    
    
    
    ///Allows you to approve a request from the user to the community. More - https://vk.com/dev/groups.approveRequest
    public static func approveRequest(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.approveRequest", parameters: parameters)
    }
    
    
    
    ///Returns list of groups of selected category. More - https://vk.com/dev/groups.getCatalog
    public static func getCatalog(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getCatalog", parameters: parameters)
    }
    
    
    
    ///Returns list of categories of selected group. More - https://vk.com/dev/groups.getCatalogInfo
    public static func getCatalogInfo(_ parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "groups.getCatalogInfo", parameters: parameters)
    }
  }
}

