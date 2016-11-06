extension _VKAPI {
  ///Methods for working with notes. More - https://vk.com/dev/notes
  public struct Notes {



    ///Returns a list of notes created by a user. More - https://vk.com/dev/notes.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.get", parameters: parameters)
    }



    ///Returns a note by its ID. More - https://vk.com/dev/notes.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.getById", parameters: parameters)
    }



    ///Returns a list of a user's friends' notes. More - https://vk.com/dev/notes.getFriendsNotes
    public static func getFriendsNotes(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.getFriendsNotes", parameters: parameters)
    }



    ///Creates a new note for the current user. More - https://vk.com/dev/notes.add
    public static func add(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.add", parameters: parameters)
    }



    ///Edits a note of the current user. More - https://vk.com/dev/notes.edit
    public static func edit(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.edit", parameters: parameters)
    }



    ///Deletes a note of the current user. More - https://vk.com/dev/notes.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.delete", parameters: parameters)
    }



    ///Returns a list of comments on a note. More - https://vk.com/dev/notes.getComments
    public static func getComments(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.getComments", parameters: parameters)
    }



    ///Adds a new comment on a note. More - https://vk.com/dev/notes.createComment
    public static func createComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.createComment", parameters: parameters)
    }



    ///Edits a comment on a note. More - https://vk.com/dev/notes.editComment
    public static func editComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.editComment", parameters: parameters)
    }



    ///Deletes a comment on a note. More - https://vk.com/dev/notes.deleteComment
    public static func deleteComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.deleteComment", parameters: parameters)
    }



    ///Restores a deleted comment on a note. More - https://vk.com/dev/notes.restoreComment
    public static func restoreComment(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "notes.restoreComment", parameters: parameters)
    }
  }
}
