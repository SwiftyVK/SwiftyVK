extension _VKAPI {
  ///Methods for working with polls. More - https://vk.com/dev/polls
  public struct Polls {
    
    
    
    ///Returns detailed information about a poll by its ID. More - https://vk.com/dev/polls.getById
    public static func getById(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.getById", parameters: parameters)
    }
    
    
    
    ///Adds the current user's vote to the selected answer in the poll. More - https://vk.com/dev/polls.addVote
    public static func addVote(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.addVote", parameters: parameters)
    }
    
    
    
    ///Deletes the current user's vote from the selected answer in the poll. More - https://vk.com/dev/polls.deleteVote
    public static func deleteVote(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.deleteVote", parameters: parameters)
    }
    
    
    
    ///Returns a list of IDs of users who selected specific answers in the poll. More - https://vk.com/dev/polls.getVoters
    public static func getVoters(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.getVoters", parameters: parameters)
    }
    
    
    
    ///Creates polls that can be attached to the users' or communities' posts. More - https://vk.com/dev/polls.create
    public static func create(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.create", parameters: parameters)
    }
    
    
    
    ///Edits created polls. More - https://vk.com/dev/polls.edit
    public static func edit(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "polls.edit", parameters: parameters)
    }
  }
}
