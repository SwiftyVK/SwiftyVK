extension _VKAPI {
  ///Methods for working with messages. More - https://vk.com/dev/messages
  public struct Messages {

    ///Returns a list of the current user's incoming or outgoing private messages. More - https://vk.com/dev/messages.get
    public static func get(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.get", parameters: parameters)
    }

    ///Returns a list of the current user's conversations. More - https://vk.com/dev/messages.getDialogs
    public static func getDialogs(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getDialogs", parameters: parameters)
    }

    ///Returns messages by their IDs. More - https://vk.com/dev/messages.getById
    public static func getById(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getById", parameters: parameters)
    }

    ///Returns a list of the current user's private messages that match search criteria. More - https://vk.com/dev/messages.search
    public static func search(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.search", parameters: parameters)
    }

    ///Returns message history for the specified user or group chat. More - https://vk.com/dev/messages.getHistory
    public static func getHistory(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getHistory", parameters: parameters)
    }

    ///Sends a message. More - http://vk.com/dev/messages.send
    public static func send(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.send", parameters: parameters)
    }

    ///Deletes one or more messages. More - https://vk.com/dev/messages.delete
    public static func delete(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.delete", parameters: parameters)
    }

    ///Deletes all private messages in a conversation. More - https://vk.com/dev/messages.deleteDialog
    public static func deleteDialog(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.deleteDialog", parameters: parameters)
    }

    ///Restores a deleted message. More - http://vk.com/dev/messages.restore
    public static func restore(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.restore", parameters: parameters)
    }

    ///Marks messages as read. More - http://vk.com/dev/messages.markAsRead
    public static func markAsRead(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.markAsRead", parameters: parameters)
    }

    ///Marks and unmarks messages as important (starred). More - http://vk.com/dev/messages.markAsImportant
    public static func markAsImportant(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.markAsImportant", parameters: parameters)
    }

    ///Returns data required for connection to a Long Poll server. More - https://vk.com/dev/messages.getLongPollServer
    public static func getLongPollServer(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getLongPollServer", parameters: parameters)
    }

    ///Returns updates in user's private messages. More - https://vk.com/dev/messages.getLongPollHistory
    public static func getLongPollHistory(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getLongPollHistory", parameters: parameters)
    }

    ///Returns information about a chat. More - https://vk.com/dev/messages.getChat
    public static func getChat(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getChat", parameters: parameters)
    }

    ///Creates a chat with several participants. More - https://vk.com/dev/messages.createChat
    public static func createChat(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.createChat", parameters: parameters)
    }

    ///Edits the title of a chat. More - https://vk.com/dev/messages.editChat
    public static func editChat(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.editChat", parameters: parameters)
    }

    ///Returns a list of IDs of users participating in a chat. More - https://vk.com/dev/messages.getChatUsers
    public static func getChatUsers(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getChatUsers", parameters: parameters)
    }

    ///Changes the status of a user as typing in a conversation. More - https://vk.com/dev/messages.setActivity
    public static func setActivity(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.setActivity", parameters: parameters)
    }

    ///Returns a list of the current user's conversations that match search criteria. More - https://vk.com/dev/messages.searchDialogs
    public static func searchDialogs(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.searchDialogs", parameters: parameters)
    }

    ///Adds a new user to a chat. More - https://vk.com/dev/messages.addChatUser
    public static func addChatUser(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.addChatUser", parameters: parameters)
    }

    ///Allows the current user to leave a chat or, if the current user started the chat, allows the user to remove another user from the chat.
    ///More - https://vk.com/dev/messages.removeChatUser
    public static func removeChatUser(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.removeChatUser", parameters: parameters)
    }

    ///Returns a user's current status and date of last activity. More - https://vk.com/dev/messages.getLastActivity
    public static func getLastActivity(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getLastActivity", parameters: parameters)
    }

    ///Sets a previously-uploaded picture as the cover picture of a chat. More - https://vk.com/dev/messages.setChatPhoto
    public static func setChatPhoto(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.setChatPhoto", parameters: parameters)
    }

    ///Deletes a chat's cover picture. More - https://vk.com/dev/messages.deleteChatPhoto
    public static func deleteChatPhoto(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.deleteChatPhoto", parameters: parameters)
    }

    ///Returns dialog attachments. More - https://vk.com/dev/messages.getHistoryAttachments
    public static func getHistoryAttachments(_ parameters: [VK.Arg : String] = [:]) -> RequestConfig {
      return RequestConfig(method: "messages.getHistoryAttachments", parameters: parameters)
    }
  }
}
