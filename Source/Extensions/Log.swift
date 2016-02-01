import Foundation

internal let printQueue = dispatch_queue_create("VK.Print", DISPATCH_QUEUE_SERIAL)
private let logQueue = dispatch_queue_create("VK.Log", DISPATCH_QUEUE_SERIAL)

private let form : NSDateFormatter = {
  let f = NSDateFormatter()
  f.dateFormat = NSDateFormatter.dateFormatFromTemplate("d.M HH:mm:ss", options: 0, locale: NSLocale.currentLocale())
  return f
}();



extension VK {
  public struct Log {
    private static var array = [String]()
    private static var dictionary = NSMutableDictionary()
    
    public static func get() -> NSDictionary {
      return NSDictionary(dictionary: dictionary)
    }
    
    
    internal static func put(req: Request, _ message: String) {
      dispatch_sync(logQueue) {
        let date = form.stringFromDate(NSDate())
        req.log.append("\(date): \(message)")
        let key = String("Req \(req.id)")
        
        if dictionary.count >= 100 {
          let keyToRemove = array.removeFirst()
          dictionary.removeObjectForKey(keyToRemove)
        }
        
        _put(key, message, false)
        req.allowLogToConsole == true
          ? printSync("\(date): \(key) ~ \(message)")
          : ()
      }
    }
    
    
    internal static func put(key: String, _ message: String) {
      dispatch_sync(logQueue) {
        _put(key, message, VK.defaults.allowLogToConsole)
      }
    }
    
    
    
    private static func _put(key: String, _ message: String, _ printToConsole: Bool) {
      let date = form.stringFromDate(NSDate())
      
      if dictionary[key] == nil {
        array.append(key)
        dictionary[key] = NSMutableArray()
      }
      
      if let dict = dictionary[key] as? NSMutableArray {
        if dict.count >= 100 {
          dict.removeObjectAtIndex(0)
        }
        dict.addObject("\(date): \(message)")
      }
      
      printToConsole == true
        ? printSync("\(date): \(key) ~ \(message)")
        : ()
    }
    
    
    
    public static func purge() {
      dispatch_sync(logQueue) {
        array = [String]()
        dictionary = NSMutableDictionary()
      nextRequestId = 0
      }
    }
  }
}
 
 
 
 /**Print to console synchronously*/
internal func printSync(some : Any) {
  dispatch_sync(printQueue) {
    print(some)
  }
}



internal func printAsync(some : Any) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
    printSync(some)
  }
}

