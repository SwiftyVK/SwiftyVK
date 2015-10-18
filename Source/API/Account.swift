extension _VKAPI {
  ///Methods for working with User Account. More - https://vk.com/dev/account
  public struct Account {
    
    
    
    ///Returns non-null values of user counters. More - https://vk.com/dev/account.getCounters
    public static func getCounters(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getCounters", parameters: parameters)
    }
    
    
    
    ///Sets an application screen name (up to 17 characters), that is shown to the user in the left menu. More - https://vk.com/dev/account.setNameInMenu
    public static func setNameInMenu(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setNameInMenu", parameters: parameters)
    }
    
    
    
    ///Marks the current user as online for 15 minutes. More - https://vk.com/dev/account.setOnline
    public static func setOnline(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setOnline", parameters: parameters)
    }
    
    
    
    ///Marks a current user as Offline. More - https://vk.com/dev/account.setOffline
    public static func setOffline(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setOffline", parameters: parameters)
    }
    
    
    
    ///Allows to search the VK users using phone nubmers, e-mail addresses and user IDs on other services. More - https://vk.com/dev/account.lookupContacts
    public static func lookupContacts(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.lookupContacts", parameters: parameters)
    }
    
    
    
    ///Subscribes an iOS/Android-based device to receive push notifications. More - https://vk.com/dev/account.registerDevice
    public static func registerDevice(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.registerDevice", parameters: parameters)
    }
    
    
    
    ///Unsubscribes a device from push notifications. More - https://vk.com/dev/account.unregisterDevice
    public static func unregisterDevice(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.unregisterDevice", parameters: parameters)
    }
    
    
    
    ///Mutes in parameters of sent push notifications for the set period of time. More - https://vk.com/dev/account.setSilenceMode
    public static func setSilenceMode(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setSilenceMode", parameters: parameters)
    }
    
    
    
    ///Gets settings of push notifications. More - https://vk.com/dev/account.getPushSettings
    public static func getPushSettings(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getPushSettings", parameters: parameters)
    }
    
    
    
    ///Sets settings of push notifications. More - https://vk.com/dev/account.getPushSettings
    public static func setPushSettings(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setPushSettings", parameters: parameters)
    }
    
    
    
    ///Gets settings of the current user in this application. More - https://vk.com/dev/account.getAppPermissions
    public static func getAppPermissions(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getAppPermissions", parameters: parameters)
    }
    
    
    
    ///Returns a list of active ads (offers) which executed by the user will bring him/her respective number of votes to his balance in the application. More - https://vk.com/dev/account.getActiveOffers
    public static func getActiveOffers(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getActiveOffers", parameters: parameters)
    }
    
    
    
    ///Adds user to the banlist. More - https://vk.com/dev/account.banUser
    public static func banUser(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.banUser", parameters: parameters)
    }
    
    
    
    ///Deletes user from the banlist. More - https://vk.com/dev/account.unbanUser
    public static func unbanUser(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.unbanUser", parameters: parameters)
    }
    
    
    
    ///Returns a user's blacklist, находящихся в черном списке. More - https://vk.com/dev/account.getBanned
    public static func getBanned(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getBanned", parameters: parameters)
    }
    
    
    
    ///Returns current account info. More - https://vk.com/dev/account.getInfo
    public static func getInfo(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getInfo", parameters: parameters)
    }
    
    
    
    ///Allows to edit the current account info. More - https://vk.com/dev/account.setInfo
    public static func setInfo(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.setInfo", parameters: parameters)
    }
    
    
    
    ///Changes a user password after access is successfully restored with the auth.restore method. More - https://vk.com/dev/account.changePassword
    public static func changePassword(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.changePassword", parameters: parameters)
    }
    
    
    
    ///Returns the current account info. More - https://vk.com/dev/account.getProfileInfo
    public static func getProfileInfo(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.getProfileInfo", parameters: parameters)
    }
    
    
    
    ///Edits current profile info. More - https://vk.com/dev/account.saveProfileInfo
    public static func saveProfileInfo(parameters: [VK.Arg : String]?) -> Request {
      return Request(method: "account.saveProfileInfo", parameters: parameters)
    }
  }
}
