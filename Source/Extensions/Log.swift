import Foundation

internal let printQueue = dispatch_queue_create("VK.Print", DISPATCH_QUEUE_SERIAL)
private let logQueue = dispatch_queue_create("VK.Log", DISPATCH_QUEUE_SERIAL)

private let cal = NSCalendar.currentCalendar()
private let form : NSDateFormatter = {
  let f = NSDateFormatter()
  f.dateStyle = .ShortStyle
  f.timeStyle = .MediumStyle
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
        
        req.log.append(message)
        let key = String("Req \(req.id)")
        
        if dictionary.count >= 100 {
          let keyToRemove = array.removeFirst()
          dictionary.removeObjectForKey(keyToRemove)
        }
        
        _put(key, message, false)
        req.allowLogToConsole == true
          ? printSync("\(key): \(message)")
          : ()
      }
    }
    
    
    internal static func put(key: String, _ message: String) {
      dispatch_sync(logQueue) {
        _put(key, message, VK.defaults.allowLogToConsole)
      }
    }
    
    
    
    private static func _put(key: String, _ message: String, _ printToConsole: Bool) {
      if dictionary[key] == nil {
        array.append(key)
        dictionary[key] = NSMutableArray()
      }
      
      if let dict = dictionary[key] as? NSMutableArray {
        if dict.count >= 100 {
          dict.removeObjectAtIndex(0)
        }
        dict.addObject(message)
      }
      
      printToConsole == true
        ? printSync("\(key): \(message)")
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



/**
 Log API work
 - parameter options Work type
 - parameter object  Any
 */
 //internal func VK.Log.put(options: [LogOption], key: String, _ message: String) {
 //  var containOption = false
 //
 //  for option in options {
 //    if VK.defaults.logOptions.contains(LogOption.all) == true || VK.defaults.logOptions.contains(option) == true {
 //      containOption = true
 //      break
 //    }
 //  }
 //
 //  guard containOption == true || VK.defaults.logOptions.contains(LogOption.all) else {return}
 //
 //  let options = options.map({(opt: LogOption) -> String in return opt.rawValue}).joinWithSeparator(", ")
 //  let thread = "name: \(NSThread.currentThread().name != "" ? NSThread.currentThread().name! : "-") num: \(NSThread.currentThread().valueForKeyPath("private.seqNum")!)"
 //  VK.defaults.logOptions.contains(LogOption.noDebug)
 //    ? printSync(message)
 //    : printSync("⏳\(form.stringFromDate(NSDate()))🚦\(thread)📌\(options)\n   \(message)\n👾")
 //}
 
 
 
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

