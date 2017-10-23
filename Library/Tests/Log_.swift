import Foundation



internal let printQueue = dispatch_queue_create("VK.Log", DISPATCH_QUEUE_SERIAL)



/**Print to console synchronously*/
internal func printSync<T>(object : T) {
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
    dispatch_sync(printQueue, {
      print(object)
    })
  })
}

