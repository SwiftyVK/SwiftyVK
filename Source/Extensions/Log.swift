import Foundation



internal let printQueue = dispatch_queue_create("VK.Log", DISPATCH_QUEUE_SERIAL)


/**
Log options to trace API work
*/
public enum LogOption {
  case all
  case thread
  case APIBlock
  case error
  case response
  case life
  case upload
  case token
  case createHTTP
  case connection
  case views
  case request
  case parameters
  case urlReq
  case longPool
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
  
  if containsAllOptions == true || VK.defaults.logOptions.contains(LogOption.all) {
    let thread = "\(NSDate()) Log in thread: \(NSThread.currentThread()))"
    printSync("\n\(thread)\n -> \(object)\n")
  }
}



/**Print to console synchronously*/
internal func printSync<T>(object : T) {
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
    dispatch_sync(printQueue, {
      print(object)
    })
  })
}

