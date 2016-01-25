import Foundation



internal let printQueue = dispatch_queue_create("VK.Log", DISPATCH_QUEUE_SERIAL)
private let cal = NSCalendar.currentCalendar()
private let form : NSDateFormatter = {
  let f = NSDateFormatter()
  f.dateStyle = .ShortStyle
  f.timeStyle = .MediumStyle
  return f
}();

/**
 Log options to trace API work
 */
public enum LogOption : String {
  case all
  case thread
  case APIBlock
  case error
  case response
  case life
  case upload
  case token
  case connection
  case views
  case request
  case reqParameters
  case urlReqCreation
  case httpCreation
  case longPool
  case noDebug
}


/**
 Log API work
 - parameter options Work type
 - parameter object  Any
 */
internal func Log<T>(options: [LogOption], _ object : T) {
  var containsAllOptions = false
  
  for option in options {
    if VK.defaults.logOptions.contains(LogOption.all) == true || VK.defaults.logOptions.contains(option) == true {
      containsAllOptions = true
      break
    }
  }
  
  guard containsAllOptions == true || VK.defaults.logOptions.contains(LogOption.all) else {return}
  
  let options = options.map({(opt: LogOption) -> String in return opt.rawValue}).joinWithSeparator(", ")
  let thread = "name: \(NSThread.currentThread().name != "" ? NSThread.currentThread().name! : "-") num: \(NSThread.currentThread().valueForKeyPath("private.seqNum")!)"
  VK.defaults.logOptions.contains(LogOption.noDebug)
    ? printSync(object)
    : printSync("⏳\(form.stringFromDate(NSDate()))🚦\(thread)📌\(options)\n   \(object)\n👾")
}



/**Print to console synchronously*/
internal func printSync<T>(object : T) {
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
    dispatch_sync(printQueue, {
      print(object)
    })
  })
}

