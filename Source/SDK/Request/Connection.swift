//import Foundation



private let requestsQueue = dispatch_queue_create("com.VK.requestsQueue", DISPATCH_QUEUE_SERIAL)
private let loopsQueue = dispatch_queue_create("com.VK.loopsQueue", DISPATCH_QUEUE_CONCURRENT)
private var actualRequestId : Int?


internal class Connection : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
  internal static var needLimit = false
  private var request : Request!
  var connection : NSURLConnection?
  private lazy var reqData = NSMutableData()
  private lazy var responseWaitSemaphore = dispatch_semaphore_create(0)
  
  
  
  
  internal class func tryInCurrentThread(request: Request) {    
    if request.isAPI {
      waitAPI(request)
      dispatch_async(requestsQueue, {
        Connection.lockAPI(request)
        NSThread.sleepForTimeInterval(VK.defaults.sleepTime)
        Connection.unlockAPI(request)
      })
    }
    
    VK.Log.put(request, "Send in current thread")
    do {request.response.create(try NSURLConnection.sendSynchronousRequest(request.URLRequest, returningResponse: nil))}
    catch let error as NSError {request.response.setError(VK.Error(ns: error, req: nil))}
    request.response.execute()
  }
  
  
  
  private class func waitAPI(request: Request) {
    guard request.isAPI, let actualRequestId = actualRequestId where request.id != actualRequestId else {return}
    VK.Log.put(request, "Wait API for request with id \(actualRequestId)")
  }
  
  
  
  private class func lockAPI(request: Request) {
    guard request.isAPI else {return}
    actualRequestId = request.id
    VK.Log.put(request, "Lock API")
  }
  
  
  
  private class func unlockAPI(request: Request) {
    guard request.isAPI else {return}
    VK.Log.put(request, "Unlock API")
    actualRequestId = nil
  }
  
  
  private class func limitIfNeeded(request: Request) {
    guard request.isAPI && needLimit == true else {return}
    needLimit = false
    VK.Log.put(request, "Limit requests count per second")
    NSThread.sleepForTimeInterval(1)
  }
  
  
  
  
  init?(request: Request) {
    assert(!(!request.isAsynchronous && NSThread.isMainThread() && request.catchErrors), "\n\nWe turned off the ability to send synchronous requests with catchErrors on the main thread, as it may cause a lot of non-obvious, subtle bugs. \nPlease send synchronous requests with catchErrors from other threads, or use catchErrors = false (not recommend). \nThank you for your understanding and good luck in the use SwiftyVK.\n\n")
    VK.Log.put(request, "INIT connection")
    
    self.request = request
    super.init()
    Connection.waitAPI(request)
    dispatch_async(request.isAPI ? requestsQueue : loopsQueue, {
      Connection.lockAPI(request)
      Connection.limitIfNeeded(request)
      
      dispatch_async(loopsQueue, {
        let type = (request.isAsynchronous ? "asynchronously" : "synchronously")
        VK.Log.put(request, "Send \(type) \(request.attempts) of \(request.maxAttempts) times")
        self.connection = NSURLConnection(request: request.URLRequest, delegate: self, startImmediately: true)
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: NSTimeInterval(Double(request.timeout+10))))
      })
      
      if request.isAPI {
        NSThread.sleepForTimeInterval(VK.defaults.sleepTime)
        request.isAsynchronous == true ? self.waitResponse() : ()
        Connection.unlockAPI(request)
      }
    })
    
    if request.isAsynchronous == false {
      VK.Log.put(request, "Wait to synchronous response")
      self.waitResponse()
      VK.Log.put(request, "Synchronous response is recieved")
    }
  }
  
  
  
  private func waitResponse() {
    dispatch_semaphore_wait(responseWaitSemaphore, DISPATCH_TIME_FOREVER)
  }
  
  
  
  private func finishConnection() {
    request.response.execute()
    dispatch_semaphore_signal(responseWaitSemaphore)
  }
  
  
  
  //MARK: - NSURLConnectionDataDelegate
  func connection(connection: NSURLConnection, didReceiveData data: NSData) {
    reqData.appendData(data)
    VK.Log.put(request, "Connection received \(data.length) bytes. Total \(reqData.length) bytes")
  }
  
  
  
  func connectionDidFinishLoading(connection: NSURLConnection) {
    request.response.create(reqData)
    finishConnection()
  }
  
  
  
  func connection(connection: NSURLConnection, didFailWithError error: NSError)  {
    let error = VK.Error(ns: error, req: request!)
    VK.Log.put(request, "Connection failed with error: \(error)")
    request.response.setError(error)
    finishConnection()
  }
  
  
  
  func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    dispatch_async(dispatch_get_main_queue(), {
      VK.Log.put(self.request, "Uploding file: \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
      VK.Log.put(self.request, "Executing progress block")
      self.request!.progressBlock(done: totalBytesWritten, total: totalBytesExpectedToWrite)
      VK.Log.put(self.request, "progress block is executed")
    })
  }
  
  
  deinit {
    VK.Log.put(self.request, "DEINIT connection")
  }
}