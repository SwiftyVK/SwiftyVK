extension _VKAPI {
  ///Methods for working with messages. More - https://vk.com/dev/messages
  public struct Messages {
    
    
    
    ///Returns a list of the current user's incoming or outgoing private messages. More - https://vk.com/dev/messages.get
    public static func get(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.get", parameters: parameters)
    }
    
    
    
    ///Returns a list of the current user's conversations. More - https://vk.com/dev/messages.getDialogs
    public static func getDialogs(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getDialogs", parameters: parameters)
    }
    
    
    
    ///Returns messages by their IDs. More - https://vk.com/dev/messages.getById
    public static func getById(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getById", parameters: parameters)
    }
    
    
    
    ///Returns a list of the current user's private messages that match search criteria. More - https://vk.com/dev/messages.search
    public static func search(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.search", parameters: parameters)
    }
    
    
    
    ///Returns message history for the specified user or group chat. More - https://vk.com/dev/messages.getHistory
    public static func getHistory(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getHistory", parameters: parameters)
    }
    
    
    
    ///Sends a message. More - http://vk.com/dev/messages.send
    public static func send(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.send", parameters: parameters)
    }
    
    
    
    ///Deletes one or more messages. More - https://vk.com/dev/messages.delete
    public static func delete(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.delete", parameters: parameters)
    }
    
    
    
    ///Deletes all private messages in a conversation. More - https://vk.com/dev/messages.deleteDialog
    public static func deleteDialog(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.deleteDialog", parameters: parameters)
    }
    
    
    
    ///Restores a deleted message. More - http://vk.com/dev/messages.restore
    public static func restore(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.restore", parameters: parameters)
    }
    
    
    
    ///Marks messages as read. More - http://vk.com/dev/messages.markAsRead
    public static func markAsRead(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.markAsRead", parameters: parameters)
    }
    
    
    
    ///Marks and unmarks messages as important (starred). More - http://vk.com/dev/messages.markAsImportant
    public static func markAsImportant(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.markAsImportant", parameters: parameters)
    }
    
    
    
    ///Returns data required for connection to a Long Poll server. More - https://vk.com/dev/messages.getLongPollServer
    public static func getLongPollServer(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getLongPollServer", parameters: parameters)
    }
    
    
    
    ///Returns updates in user's private messages. More - https://vk.com/dev/messages.getLongPollHistory
    public static func getLongPollHistory(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getLongPollHistory", parameters: parameters)
    }
    
    
    
    ///Returns information about a chat. More - https://vk.com/dev/messages.getChat
    public static func getChat(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getChat", parameters: parameters)
    }
    
    
    
    ///Creates a chat with several participants. More - https://vk.com/dev/messages.createChat
    public static func createChat(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.createChat", parameters: parameters)
    }
    
    
    
    ///Edits the title of a chat. More - https://vk.com/dev/messages.editChat
    public static func editChat(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.editChat", parameters: parameters)
    }
    
    
    
    ///Returns a list of IDs of users participating in a chat. More - https://vk.com/dev/messages.getChatUsers
    public static func getChatUsers(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getChatUsers", parameters: parameters)
    }
    
    
    
    ///Changes the status of a user as typing in a conversation. More - https://vk.com/dev/messages.setActivity
    public static func setActivity(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.setActivity", parameters: parameters)
    }
    
    
    
    ///Returns a list of the current user's conversations that match search criteria. More - https://vk.com/dev/messages.searchDialogs
    public static func searchDialogs(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.searchDialogs", parameters: parameters)
    }
    
    
    
    ///Adds a new user to a chat. More - https://vk.com/dev/messages.addChatUser
    public static func addChatUser(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.addChatUser", parameters: parameters)
    }
    
    
    
    ///Allows the current user to leave a chat or, if the current user started the chat, allows the user to remove another user from the chat. More - https://vk.com/dev/messages.removeChatUser
    public static func removeChatUser(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.removeChatUser", parameters: parameters)
    }
    
    
    
    ///Returns a user's current status and date of last activity. More - https://vk.com/dev/messages.getLastActivity
    public static func getLastActivity(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.getLastActivity", parameters: parameters)
    }
    
    
    
    ///Sets a previously-uploaded picture as the cover picture of a chat. More - https://vk.com/dev/messages.setChatPhoto
    public static func setChatPhoto(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.setChatPhoto", parameters: parameters)
    }
    
    
    
    ///Deletes a chat's cover picture. More - https://vk.com/dev/messages.deleteChatPhoto
    public static func deleteChatPhoto(parameters: [VK.Arg : String] = [:]) -> Request {
      return Request(method: "messages.deleteChatPhoto", parameters: parameters)
    }
  }
}
