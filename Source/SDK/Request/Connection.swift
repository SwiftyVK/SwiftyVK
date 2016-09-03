//import Foundation



private let apiQueue = dispatch_queue_create("com.VK.requestsQueue", DISPATCH_QUEUE_SERIAL)
private let notApiQueue = dispatch_queue_create("com.VK.loopsQueue", DISPATCH_QUEUE_CONCURRENT)

private var actualRequestId : Int?


internal class Connection : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
  internal static var needLimit = false
  private var request : Request!
  private lazy var reqData = NSMutableData()
  private lazy var responseWaitSemaphore = dispatch_semaphore_create(0)
  private lazy var timeoutOperation : NSBlockOperation? = NSBlockOperation()
  private let delegateQueue = NSOperationQueue()
  private let timeoutQueue = NSOperationQueue()
  private var canFinish = true
  private let finishQueue = dispatch_queue_create("com.VK.finishQueue", DISPATCH_QUEUE_SERIAL)
  
  
  
  internal class func tryInCurrentThread(request: Request) {
    if request.isAPI {
      waitAPI(request)
      dispatch_async(apiQueue, {
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
    
    dispatch_async(request.isAPI ? apiQueue : notApiQueue, {
      guard !request.cancelled else {return}
      
      VK.Log.putToRequestsQueue(request)
      Connection.lockAPI(request)
      Connection.limitIfNeeded(request)
      
      let connection = NSURLConnection(request: request.URLRequest, delegate: self, startImmediately: false)
      connection?.setDelegateQueue(self.delegateQueue)
      connection?.start()
      let type = (request.isAsynchronous ? "asynchronously" : "synchronously")
      VK.Log.put(request, "Send \(type) \(request.attempts) of \(request.maxAttempts) times")
      self.addTimeout()
      
      if request.isAPI {
        NSThread.sleepForTimeInterval(VK.defaults.sleepTime)
        request.isAsynchronous == true ? self.waitResponse() : ()
        Connection.unlockAPI(request)
      }
    })
    
    if request.isAsynchronous == false {
      self.waitResponse()
    }
  }
  
  
  
  private func addTimeout() {
    let op = NSBlockOperation() {
      NSThread.sleepForTimeInterval(Double(self.request.timeout+1))
      if self.timeoutOperation?.cancelled == false {
        let error = VK.Error(domain: "APIDomain", code: 7, desc: "Connection timeout", userInfo: nil, req: self.request)
        VK.Log.put(self.request, "Connection time out")
        self.request.response.setError(error)
        self.finishConnection()
      }
    }
    
    self.timeoutOperation = op
    timeoutQueue.addOperation(op)
  }
  
  
  
  private func waitResponse() {
    let type = (request.isAsynchronous ? "asynchronous" : "synchronous")
    VK.Log.put(request, "Wait to \(type) response")
    dispatch_semaphore_wait(responseWaitSemaphore, DISPATCH_TIME_FOREVER)
    VK.Log.put(request, "\(type) response is recieved")
    VK.Log.removeFromRequestsQueue(request)
  }
  
  
  
  private func finishConnection() {
    dispatch_sync(finishQueue) {
      guard self.canFinish else {return}
      self.canFinish = false
      self.timeoutOperation?.cancel()
      self.timeoutOperation = nil
      self.request.response.execute()
      dispatch_semaphore_signal(self.responseWaitSemaphore)
    }
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
    VK.Log.put(request, "Uploding file: \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
    request!.progressBlock(done: totalBytesWritten, total: totalBytesExpectedToWrite)
  }
  
  
  deinit {
    VK.Log.put(self.request, "DEINIT connection")
  }
}