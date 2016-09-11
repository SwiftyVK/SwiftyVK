import Foundation


///Types of grand central dispatch global queues and executes
internal struct GCDTypes {
  ///Types of grand central dispatch global queues
  enum Queue {
    ///equivalently dispatch_get_main_queue()
    case main
    ///equivalently DISPATCH_QUEUE_PRIORITY_BACKGROUND
    case back
    ///equivalently DISPATCH_QUEUE_PRIORITY_HIGH
    case high
    ///equivalently DISPATCH_QUEUE_PRIORITY_DEFAULT
    case def
    ///equivalently DISPATCH_QUEUE_PRIORITY_LOW
    case low
  }
  
  ///Execute types of grand central dispatch
  enum ExecuteType {
    ///equivalently dispatch_sync
    case sync
    ///equivalently dispatch_async
    case async
    ///equivalently dispatch_barrier_sync
    case bsync
    ///equivalently dispatch_barrier_async
    case basync
  }
}



///Send
internal func GCD(sendType: GCDTypes.ExecuteType, _ queue: dispatch_queue_t, _ block: () -> ()) {
  
  switch sendType {
  case .sync:
    queue.isEqual(dispatch_get_main_queue()) && NSThread.isMainThread()
      ? block()
      : dispatch_sync(queue, block)
  case .async:
    dispatch_async(queue, block)
  case .bsync:
    dispatch_barrier_sync(queue, block)
  case .basync:
      dispatch_barrier_async(queue, block)
  }
}



internal func GCD(sendType: GCDTypes.ExecuteType, _ queueType: GCDTypes.Queue, _ block: () -> ()) {
  var queue : dispatch_queue_t
  
  switch queueType {
  case .main:
    queue = dispatch_get_main_queue()
  case .back:
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
  case .high:
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
  case .def:
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
  case .low:
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
  }
  
  switch sendType {
  case .sync:
    queueType == .main && NSThread.isMainThread()
      ? block()
      : dispatch_sync(queue, block)
  case .async:
    dispatch_async(queue, block)
  case .bsync:
    dispatch_barrier_sync(queue, block)
  case .basync:
    dispatch_barrier_async(queue, block)
  }
}