extension _VKAPI {
  ///Methods for working with discussion boards. More - https://vk.com/dev/board
  public struct Board {
    
    
    
    ///Returns a list of topics on a community's discussion board. More - https://vk.com/dev/board.getTopics
    public static func getTopics(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.getTopics", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a topic on a community's discussion board. More - https://vk.com/dev/board.getComments
    public static func getComments(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.getComments", parameters: parameters)
    }
    
    
    
    ///Creates a new topic on a community's discussion board. More - https://vk.com/dev/board.addTopic
    public static func addTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.addTopic", parameters: parameters)
    }
    
    
    
    ///Adds a comment on a topic on a community's discussion board. More - https://vk.com/dev/board.addComment
    public static func addComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.addComment", parameters: parameters)
    }
    
    
    
    ///Deletes a topic from a community's discussion board. More - https://vk.com/dev/board.deleteTopic
    public static func deleteTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.deleteTopic", parameters: parameters)
    }
    
    
    
    ///Edits the title of a topic on a community's discussion board. More - https://vk.com/dev/board.editTopic
    public static func editTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.editTopic", parameters: parameters)
    }
    
    
    
    ///Edits a comment on a topic on a community's discussion board. More - https://vk.com/dev/board.editComment
    public static func editComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.editComment", parameters: parameters)
    }
    
    
    
    ///Restores a comment deleted from a topic on a community's discussion board. More - https://vk.com/dev/board.restoreComment
    public static func restoreComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.restoreComment", parameters: parameters)
    }
    
    
    
    ///Deletes a comment on a topic on a community's discussion board. More - https://vk.com/dev/board.deleteComment
    public static func deleteComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.deleteComment", parameters: parameters)
    }
    
    
    
    ///Re-opens a previously closed topic on a community's discussion board. More - https://vk.com/dev/board.openTopic
    public static func openTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.openTopic", parameters: parameters)
    }
    
    
    
    ///Closes a topic on a community's discussion board so that comments cannot be posted. More - https://vk.com/dev/board.closeTopic
    public static func closeTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.closeTopic", parameters: parameters)
    }
    
    
    
    ///Pins a topic (fixes its place) to the top of a community's discussion board. More - https://vk.com/dev/board.fixTopic
    public static func fixTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.fixTopic", parameters: parameters)
    }
    
    
    
    ///Unpins a pinned topic from the top of a community's discussion board. More - https://vk.com/dev/board.unfixTopic
    public static func unfixTopic(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "board.unfixTopic", parameters: parameters)
    }
  }
}
