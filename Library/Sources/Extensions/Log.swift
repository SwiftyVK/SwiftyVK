import Foundation

internal let printQueue = DispatchQueue(label: "SwiftyVK.PrintQueue")
internal let logQueue = DispatchQueue(label: "SwiftyVK.LogQueue")

private let form : DateFormatter = {
  let f = DateFormatter()
  f.dateFormat = DateFormatter.dateFormat(fromTemplate: "d.M HH:mm:ss", options: 0, locale: Locale.current)
  return f
}();



extension VK {
  public struct Log {
    private static var requestsQueue = NSMutableArray()
    private static var all = [String]()
    private static var array = [String]()
    private static var dictionary = NSMutableDictionary()
    private static var reqId: Int64 = 0
    private static var taskId: Int64 = 0

    
    
    internal static func generateRequestId() -> Int64 {
        return logQueue.sync {
            reqId += 1
            return reqId
        }
    }
    
    
    internal static func generateTaskId() -> Int64 {
        return logQueue.sync {
            taskId += 1
            return taskId
        }
    }
    
    
    public static func getForKeys() -> NSDictionary {
      return NSDictionary(dictionary: dictionary)
    }
    
    
    
    public static func getAll() -> [String] {
      return all
    }
    
    
    
    public static func getRequestsQueue() -> NSArray {
      return NSArray(array: requestsQueue)
    }
    
    
    
    internal static func put(_ req: RequestInstance, _ message: String, atNewLine: Bool = false) {
      let block = {
        let date = form.string(from: Date())
        req.log.append("\(date): \(message)")
        let key = String("Req \(req.id)")!
        
        if dictionary.count >= 100 {
          let keyToRemove = array.removeFirst()
          dictionary.removeObject(forKey: keyToRemove)
        }
        
        self._put(key, message, false)
        if req.config.logToConsole {
            printSync("\(atNewLine ? "\n" : "")\(date): \(key) ~ \(message)")
        }
      }
        
      logQueue.async(execute: block)
    }
    
    
    
    internal static func put(_ reqId: Int64, _ message: String) {
        logQueue.async {
            _put("Req \(reqId)", message, VK.config.logToConsole)
        }
    }
    
    
    
    internal static func put(_ key: String, _ message: String) {
      logQueue.async {
        _put(key, message, VK.config.logToConsole)
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
        reqId = 0
        taskId = 0
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

