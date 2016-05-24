import Foundation



private var tokenInstance : Token! {
  willSet {
    if newValue != nil {
      Token.notifyExist()
    }
    else {
      Token.notifyNotExist()
    }
  }
}



internal class Token: NSObject, NSCoding {
  
  internal private(set) static var revoke = true
  
  private var token       : String
  private var expires     : Int
  private var isOffline   = false
  private var parameters  : Dictionary<String, String>
  
  override var description : String {
    return "Token with parameters: \(parameters))"
  }
  
  
  
  init(urlString: String) {
    let parameters = Token.parse(urlString)
    token       = parameters["access_token"]!
    expires     = 0 + Int(NSDate().timeIntervalSince1970)
    if parameters["expires_in"] != nil {expires += Int(parameters["expires_in"]!)!}
    isOffline   = (parameters["expires_in"]?.isEmpty == false && (Int(parameters["expires_in"]!) == 0) || parameters["expires_in"] == nil)
    self.parameters = parameters
    
    super.init()
    tokenInstance = self
    Token.revoke = true
    VK.Log.put("Token", "INIT \(self)")
    save()
  }
  
  
  
  
  init(token: String, expires : Int = 0, parameters: Dictionary<String, String> = [:]) {
    self.token = token
    self.expires = expires
    self.parameters = parameters
    
    super.init()
    tokenInstance = self
    Token.revoke = true
    VK.Log.put("Token", "INIT \(self)")
    save()
  }
  
  
  
  class func get() -> String? {
    VK.Log.put("Token", "Getting")
    
    if tokenInstance != nil && self.isExpired() == false {
      return tokenInstance.token
    }
    else if let _ = _load() where self.isExpired() == false {
      return tokenInstance.token
    }
    return nil
  }
  
  
  
  class var exist : Bool {
    return tokenInstance != nil
  }
  
  
  
  private class func parse(request: String) -> Dictionary<String, String> {
    let cleanRequest  = request.componentsSeparatedByString("#")[1]
    let preParameters = cleanRequest.componentsSeparatedByString("&")
    var parameters    = Dictionary<String, String>()
    
    for keyValueString in preParameters {
      let keyValueArray = keyValueString.componentsSeparatedByString("=")
      parameters[keyValueArray[0]] = keyValueArray[1]
    }
    VK.Log.put("Token", "Parse from parameters: \(parameters)")
    return parameters
  }
  
  
  
  private class func isExpired() -> Bool {
    if tokenInstance == nil {
      return true
    }
    else if tokenInstance.isOffline == false && tokenInstance.expires < Int(NSDate().timeIntervalSince1970) {
      VK.Log.put("Token", "Expired")
      revoke = false
      Token.remove()
      return true
    }
    return false
  }
  
  
  
  private class func _load() -> Token? {
    let parameters  = VK.delegate.vkTokenPath()
    let useDefaults = parameters.useUserDefaults
    let filePath    = parameters.alternativePath
    if useDefaults {tokenInstance = self.loadFromDefaults()}
    else           {tokenInstance = self.loadFromFile(filePath)}
    return tokenInstance
  }
  
  
  
  private class func loadFromDefaults() -> Token? {
    let defaults = NSUserDefaults.standardUserDefaults()
    if !(defaults.objectForKey("Token") != nil) {return nil}
    let object: AnyObject! = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("Token") as! NSData)
    if object == nil {
      VK.Log.put("Token", "Load from NSUSerDefaults failed")
      return nil
    }
    VK.Log.put("Token", "Loaded from NSUserDefaults")
    return object as? Token
  }
  
  ///Загрузка из файла
  private class func loadFromFile(filePath : String) -> Token? {
    let manager = NSFileManager.defaultManager()
    if !manager.fileExistsAtPath(filePath) {
      VK.Log.put("Token", "Loaded from file \(filePath) failed")
      return nil
    }
    let token = (NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)) as? Token
    VK.Log.put("Token", "Loaded from file: \(filePath)")
    return token
  }
  
  
  
  func save() {
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
    VK.Log.put("Token", "Saved to NSUserDefaults")
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
    VK.Log.put("Token", "Saved to file: \(filePath)")
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
        do {try manager.removeItemAtPath(filePath)}
        catch _ {}
      }
    }
    
    if tokenInstance != nil {tokenInstance = nil}
    VK.Log.put("Token", "Remove")
  }
  
  
  
  private class func notifyExist() {
    if VK.state != .Authorized {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        NSThread.sleepForTimeInterval(0.1)
        if tokenInstance != nil {
          VK.delegate.vkDidAutorize(tokenInstance.parameters)
        }
      }
    }
  }
  
  
  private class func notifyNotExist() {
    if VK.state == .Authorized {
      VK.delegate.vkDidUnautorize()
    }
  }
  
  
  
  deinit {VK.Log.put("Token", "DEINIT \(self)")}
  
  
  
  //MARK: - NSCoding protocol
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(parameters,  forKey: "parameters")
    aCoder.encodeObject(token,       forKey: "token")
    aCoder.encodeInteger(expires,    forKey: "expires")
    aCoder.encodeBool(isOffline,     forKey: "isOffline")
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    token         = aDecoder.decodeObjectForKey("token") as! String
    expires       = aDecoder.decodeIntegerForKey("expires")
    isOffline     = aDecoder.decodeBoolForKey("isOffline")
    
    if let parameters = aDecoder.decodeObjectForKey("parameters") as? Dictionary<String, String> {
      self.parameters = parameters
    }
    else {
      self.parameters = [:]
    }

  }
}

