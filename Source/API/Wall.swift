extension _VKAPI {
  ///Methods for working with walls. More - https://vk.com/dev/friends
  public struct Wall {
    
    
    
    ///Returns a list of posts on a user wall or community wall. More - https://vk.com/dev/wall.get
    public static func get(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.get", parameters: parameters)
    }
    
    
    
    ///Allows to search posts on user or community walls. More - https://vk.com/dev/wall.search
    public static func search(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.search", parameters: parameters)
    }
    
    
    
    ///Returns a list of posts from user or community walls by their IDs. More - https://vk.com/dev/wall.getById
    public static func getById(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.getById", parameters: parameters)
    }
    
    
    
    ///Adds a new post on a user wall or community wall. Can also be used to publish suggested or scheduled posts. More - https://vk.com/dev/wall.post
    public static func post(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.post", parameters: parameters)
    }
    
    
    
    ///Reposts (copies) an object to a user wall or community wall. More - https://vk.com/dev/wall.repost
    public static func repost(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.repost", parameters: parameters)
    }
    
    
    
    ///Returns information about reposts of a post on user wall or community wall. More - https://vk.com/dev/wall.getReposts
    public static func getReposts(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.getReposts", parameters: parameters)
    }
    
    
    
    ///Edits a post on a user wall or community wall. More - https://vk.com/dev/wall.edit
    public static func edit(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.edit", parameters: parameters)
    }
    
    
    
    ///Deletes a post from a user wall or community wall. More - https://vk.com/dev/wall.delete
    public static func delete(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.delete", parameters: parameters)
    }
    
    
    
    ///Restores a post deleted from a user wall or community wall. More - https://vk.com/dev/wall.restore
    public static func restore(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.restore", parameters: parameters)
    }
    
    
    
    ///Fixes record on the wall (the recording will be displayed above the rest). More - https://vk.com/dev/wall.pin
    public static func pin(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.pin", parameters: parameters)
    }
    
    
    
    ///Cancels consolidation entries on the wall. More - https://vk.com/dev/wall.unpin
    public static func unpin(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.unpin", parameters: parameters)
    }
    
    
    
    ///Returns a list of comments on a post on a user wall or community wall. More - https://vk.com/dev/wall.getComments
    public static func getComments(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.getComments", parameters: parameters)
    }
    
    
    
    ///Adds a comment to a post on a user wall or community wall. More - https://vk.com/dev/wall.addComment
    public static func addComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.addComment", parameters: parameters)
    }
    
    
    
    ///Edits a comment on a user wall or community wall. More - https://vk.com/dev/wall.editComment
    public static func editComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.editComment", parameters: parameters)
    }
    
    
    
    ///Удаляет комментарий текущего пользователя к записи на своей или чужой стене. More - https://vk.com/dev/wall.deleteComment
    public static func deleteComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.deleteComment", parameters: parameters)
    }
    
    
    
    ///Deletes a comment on a post on a user wall or community wall. More - https://vk.com/dev/wall.restoreComment
    public static func restoreComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.restoreComment", parameters: parameters)
    }
    
    
    
    ///Restores a comment deleted from a user wall or community wall. More - https://vk.com/dev/wall.reportPost
    public static func reportPost(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.reportPost", parameters: parameters)
    }
    
    
    
    ///Reports (submits a complaint about) a post on a user wall or community wall. More - https://vk.com/dev/wall.reportComment
    public static func reportComment(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "wall.reportComment", parameters: parameters)
    }
  }
}


