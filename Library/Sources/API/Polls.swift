extension _VKAPI {
  ///Methods for working with polls. More - https://vk.com/dev/polls
  public struct Polls {



    ///Returns detailed information about a poll by its ID. More - https://vk.com/dev/polls.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.getById", parameters: parameters)
    }



    ///Adds the current user's vote to the selected answer in the poll. More - https://vk.com/dev/polls.addVote
    public static func addVote(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.addVote", parameters: parameters)
    }



    ///Deletes the current user's vote from the selected answer in the poll. More - https://vk.com/dev/polls.deleteVote
    public static func deleteVote(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.deleteVote", parameters: parameters)
    }



    ///Returns a list of IDs of users who selected specific answers in the poll. More - https://vk.com/dev/polls.getVoters
    public static func getVoters(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.getVoters", parameters: parameters)
    }



    ///Creates polls that can be attached to the users' or communities' posts. More - https://vk.com/dev/polls.create
    public static func create(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.create", parameters: parameters)
    }



    ///Edits created polls. More - https://vk.com/dev/polls.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "polls.edit", parameters: parameters)
    }
  }
}
