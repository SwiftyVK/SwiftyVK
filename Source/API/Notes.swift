extension _VKAPI {
  ///Methods for working with notes. More - https://vk.com/dev/notes
  public struct Notes {
    
    
    
    ///Returns a list of notes created by a user. More - https://vk.com/dev/notes.get
    public static func get(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.get", parameters: parameters)
    }
    
    
    
    ///Returns a note by its ID. More - https://vk.com/dev/notes.getById
    public static func getById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.getById", parameters: parameters)
    }
    
    
    
    ///Returns a list of a user's friends' notes. More - https://vk.com/dev/notes.getFriendsNotes
    public static func getFriendsNotes(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.getFriendsNotes", parameters: parameters)
    }
    
    
    
    ///Creates a new note for the current user. More - https://vk.com/dev/notes.add
    public static func add(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.add", parameters: parameters)
    }
    
    
    
    ///Edits a note of the current user. More - https://vk.com/dev/notes.edit
    public static func edit(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.edit", parameters: parameters)
    }
    
    
    
    ///Deletes a note of the current user. More - https://vk.com/dev/notes.delete
    public static func delete(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.delete", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a note. More - https://vk.com/dev/notes.getComments
    public static func getComments(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.getComments", parameters: parameters)
    }
    
    
    
    ///Adds a new comment on a note. More - https://vk.com/dev/notes.createComment
    public static func createComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.createComment", parameters: parameters)
    }
    
    
    
    ///Edits a comment on a note. More - https://vk.com/dev/notes.editComment
    public static func editComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.editComment", parameters: parameters)
    }
    
    
    
    ///Deletes a comment on a note. More - https://vk.com/dev/notes.deleteComment
    public static func deleteComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.deleteComment", parameters: parameters)
    }
    
    
    
    ///Restores a deleted comment on a note. More - https://vk.com/dev/notes.restoreComment
    public static func restoreComment(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "notes.restoreComment", parameters: parameters)
    }
  }
}
