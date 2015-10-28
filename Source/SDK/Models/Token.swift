import Foundation



private var privateSelf : Token!



internal class Token: NSObject, NSCoding {
  
  private var token       : String
  private var expires     : Int
  private var isOffline   = false
  
  override var description : String {
    return "Token \(token) valid to \(NSDate(timeIntervalSince1970: NSTimeInterval(expires)))"
  }
  
  
  

  init(urlString: String) {
    let parameters = Token.parseToken(urlString)
    
    token       = parameters["access_token"]!
    expires     = 0 + Int(NSDate().timeIntervalSince1970)
    if parameters["expires_in"] != nil {expires += Int(parameters["expires_in"]!)!}
    isOffline   = (parameters["expires_in"]?.isEmpty == false && (Int(parameters["expires_in"]!) == 0) || parameters["expires_in"] == nil)
    
    super.init()
    privateSelf = self
    Log([.token, .life], "\(self): \(token) INIT")
    saveToken()
  }
  
  

  class func get() -> String? {
    Log([.token], "Receiving token")
    
    if privateSelf != nil && self.isExpired() == false {
      return privateSelf.token
    }
    else if let _ = loadToken() where self.isExpired() == false {
      return privateSelf.token
    }
    return nil
  }
  

  
  private class func parseToken (request: String) -> Dictionary<String, String> {
    let cleanRequest  = request.componentsSeparatedByString("#")[1]
    let preParameters = cleanRequest.componentsSeparatedByString("&")
    var parameters    = Dictionary<String, String>()
    
    for keyValueString in preParameters {
      let keyValueArray = keyValueString.componentsSeparatedByString("=")
      parameters[keyValueArray[0]] = keyValueArray[1]
    }
    Log([.token], "Receiving token from parameters: \(parameters)")
    return parameters
  }
  

  
  private class func isExpired() -> Bool {
    let token = privateSelf
    
    if !token.isOffline && token.expires < Int(NSDate().timeIntervalSince1970) {
      Token.remove()
      WebController.autorize(false)
      return true
    }
    else {return false}
  }
  
  
  
  class func loadToken() -> Token? {
    let parameters  = VK.delegate.vkTokenPath()
    let useDefaults = parameters.useUserDefaults
    let filePath    = parameters.alternativePath
    if useDefaults {privateSelf = self.loadFromDefaults()}
    else           {privateSelf = self.loadFromFile(filePath)}
    return privateSelf
  }
  

  
  private class func loadFromDefaults() -> Token? {
    let defaults = NSUserDefaults.standardUserDefaults()
    if !(defaults.objectForKey("Token") != nil) {return nil}
    let object: AnyObject! = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("Token") as! NSData)
    if object == nil {
      Log([.token], "Load token from NSUSerDefaults failed")
      return nil
    }
    Log([.token], "Token did load from NSUserDefaults")
    return object as? Token
  }
  
  ///Загрузка из файла
  private class func loadFromFile(filePath : String) -> Token? {
    let manager = NSFileManager.defaultManager()
    if !manager.fileExistsAtPath(filePath) {
      Log([.token], "Load token from file \(filePath) failed")
      return nil
    }
    let token = (NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)) as? Token
    Log([.token], "Token did load from file: \(filePath)")
    return token
  }
  
  
  
  func saveToken() {
    let parameters  = VK.delegate.vkTokenPath()
    let useDefaults = parameters.useUserDefaults
    let filePath    = parameters.alternativePath
    if useDefaults {saveToDefaults()}
    else           {saveToFile(filePath)}
  }
  

  
  private func saveToDefaults() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self), forKey: "Token")
    defaults.synchronize()
    Log([.token], "Save token to NSUserDefaults")
  }
  

  
  private func saveToFile(filePath : String) {
    let manager = NSFileManager.defaultManager()
    if manager.fileExistsAtPath(filePath) {
      do {
        try manager.removeItemAtPath(filePath)
      }
      catch _ {}
    }
    NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    Log([.token], "Save token to file: \(filePath)")
  }
  
  
  
  class func remove() {
    
    let parameters  = VK.delegate.vkTokenPath()
    let useDefaults = parameters.useUserDefaults
    let filePath    = parameters.alternativePath
    
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey("Token") != nil {defaults.removeObjectForKey("Token")}
    defaults.synchronize()
    
    if !useDefaults {
      let manager = NSFileManager.defaultManager()
      if manager.fileExistsAtPath(filePath) {
        do {
          try manager.removeItemAtPath(filePath)
        }
        catch _ {}
      }
    }
    
    if privateSelf != nil {privateSelf = nil}
    Log([.token], "Token did remove")
  }
  
  
  
  deinit {Log([.token], "\(self) DEINIT")}
  
  
  
  //MARK: - NSCoding protocol
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(token,       forKey: "token")
    aCoder.encodeInteger(expires,    forKey: "expires")
    aCoder.encodeBool(isOffline,     forKey: "isOffline")
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    token         = aDecoder.decodeObjectForKey("token") as! String
    expires       = aDecoder.decodeIntegerForKey("expires")
    isOffline     = aDecoder.decodeBoolForKey("isOffline")
  }
}

