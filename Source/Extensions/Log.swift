import Foundation

internal let printQueue = DispatchQueue(label: "VK.Print", attributes: DispatchQueueAttributes.serial)
private let logQueue = DispatchQueue(label: "VK.Log", attributes: DispatchQueueAttributes.serial)

private let form : DateFormatter = {
  let f = DateFormatter()
  f.dateFormat = DateFormatter.dateFormat(fromTemplate: "d.M HH:mm:ss", options: 0, locale: Locale.current())
  return f
}();



extension VK {
  public struct Log {
    private static var requestsQueue = NSMutableArray()
    private static var all = [String]()
    private static var array = [String]()
    private static var dictionary = NSMutableDictionary()
    
    public static func getForKeys() -> NSDictionary {
      return NSDictionary(dictionary: dictionary)
    }
    
    
    
    public static func getAll() -> [String] {
      return all
    }
    
    
    
    public static func getRequestsQueue() -> NSArray {
      return NSArray(array: requestsQueue)
    }
    
    
    
    public static func putToRequestsQueue(_ request: Request) {
      logQueue.async {
        requestsQueue.add(request)
      }
    }
    
    
    
    public static func removeFromRequestsQueue(_ request: Request) {
      logQueue.async {
        requestsQueue.remove(request)
      }
    }
    
    
    
    internal static func put(_ req: Request, _ message: String) {
      logQueue.async {
        let date = form.string(from: Date())
        req.log.append("\(date): \(message)")
        let key = String("Req \(req.id)")
        
        if dictionary.count >= 100 {
          let keyToRemove = array.removeFirst()
          dictionary.removeObject(forKey: keyToRemove)
        }
        
        _put(key, message, false)
        req.allowLogToConsole == true
          ? printSync("\(date): \(key) ~ \(message)")
          : ()
      }
    }
    
    
    internal static func put(_ key: String, _ message: String) {
      logQueue.async {
        _put(key, message, VK.defaults.allowLogToConsole)
      }
    }
    
    
    
    private static func _put(_ key: String, _ message: String, _ printToConsole: Bool) {
      let date = form.string(from: Date())
      
      if dictionary[key] == nil {
        array.append(key)
        dictionary[key] = NSMutableArray()
      }
      
      if let dict = dictionary[key] as? NSMutableArray {
        if dict.count >= 100 {
          dict.removeObject(at: 0)
        }
        dict.add("\(date): \(message)")
      }
      
      if all.count > 100 {
        all.removeFirst()
      }
      
      all.append("\(date): \(key) ~ \(message)")
      
      printToConsole == true
        ? printSync("\(date): \(key) ~ \(message)")
        : ()
    }
    
    
    
    public static func purge() {
      logQueue.async {
        array = [String]()
        dictionary = NSMutableDictionary()
        nextRequestId = 0
      }
    }
  }
}



/**Print to console synchronously*/
internal func printSync(_ some : Any) {
  printQueue.sync {
    print(some)
  }
}



internal func printAsync(_ some : Any) {
  printQueue.async {
    printSync(some)
  }
}

