//import Foundation



private let apiQueue = DispatchQueue(label: "com.VK.requestsQueue")
private let notApiQueue = DispatchQueue(label: "com.VK.loopsQueue", attributes: .concurrent)

private var actualRequestId : Int?


internal class Connection : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
  internal static var needLimit = false
  private var request : Request!
  private lazy var reqData = NSMutableData()
  private lazy var responseWaiter = DispatchSemaphore(value: 0)
  private lazy var timeoutOperation = BlockOperation()
  private let delegateQueue = OperationQueue()
  private let timeoutQueue = OperationQueue()
  private var canFinish = true
  private let finishQueue = DispatchQueue(label: "com.VK.finishQueue")
  
  
  
  internal class func tryInCurrentThread(_ request: Request) {
    if request.isAPI {
      waitAPI(request)
      apiQueue.async(execute: {
        Connection.lockAPI(request)
        Thread.sleep(forTimeInterval: VK.defaults.sleepTime)
        Connection.unlockAPI(request)
      })
    }
    
    VK.Log.put(request, "Send in current thread")
    do {request.response.create(try NSURLConnection.sendSynchronousRequest(request.urlRequest, returning: nil))}
    catch let error as NSError {request.response.setError(VK.Error(err: error, req: nil))}
    request.response.execute()
  }
  
  
  
  private class func waitAPI(_ request: Request) {
    guard request.isAPI, let actualRequestId = actualRequestId, request.id != actualRequestId else {return}
    VK.Log.put(request, "Wait API for request with id \(actualRequestId)")
  }
  
  
  
  private class func lockAPI(_ request: Request) {
    guard request.isAPI else {return}
    actualRequestId = request.id
    VK.Log.put(request, "Lock API")
  }
  
  
  
  private class func unlockAPI(_ request: Request) {
    guard request.isAPI else {return}
    VK.Log.put(request, "Unlock API")
    actualRequestId = nil
  }
  
  
  private class func limitIfNeeded(_ request: Request) {
    guard request.isAPI && needLimit == true else {return}
    needLimit = false
    VK.Log.put(request, "Limit requests count per second")
    Thread.sleep(forTimeInterval: 1)
  }
  
  
  
  
  init?(request: Request) {
    assert(!(!request.isAsynchronous && Thread.isMainThread && request.catchErrors), "\n\nWe turned off the ability to send synchronous requests with catchErrors on the main thread, as it may cause a lot of non-obvious, subtle bugs. \nPlease send synchronous requests with catchErrors from other threads, or use catchErrors = false (not recommend). \nThank you for your understanding and good luck in the use SwiftyVK.\n\n")
    VK.Log.put(request, "INIT connection")
    
    self.request = request
    super.init()
    Connection.waitAPI(request)
    
    (request.isAPI ? apiQueue : notApiQueue).async() {
      guard !request.cancelled else {
        VK.Log.put(request, "Cancelled!")
        return
      }
      
      VK.Log.putToRequestsQueue(request)
      Connection.lockAPI(request)
      Connection.limitIfNeeded(request)
      
      let type = (request.isAsynchronous ? "asynchronously" : "synchronously")
      VK.Log.put(request, "Send \(type) \(request.attempts) of \(request.maxAttempts) times")
      
      let connection = NSURLConnection(request: request.urlRequest as URLRequest, delegate: self, startImmediately: false)
      connection?.setDelegateQueue(self.delegateQueue)
      connection?.start()
      self.addTimeout()
      
      if request.isAPI {
        Thread.sleep(forTimeInterval: VK.defaults.sleepTime)
        request.isAsynchronous == true ? self.waitResponse() : ()
        Connection.unlockAPI(request)
      }
    }
    
    if request.isAsynchronous == false {
      self.waitResponse()
    }
  }
  
  
  
  private func addTimeout() {
    self.timeoutOperation = BlockOperation() {
      Thread.sleep(forTimeInterval: Double(self.request.timeout+1))
      if self.timeoutOperation.isCancelled == false {
        let error = VK.Error(domain: "APIDomain", code: 7, desc: "Connection timeout", userInfo: nil, req: self.request)
        VK.Log.put(self.request, "Connection time out")
        self.request.response.setError(error)
        self.finishConnection()
      }
    }
    timeoutQueue.addOperation(self.timeoutOperation)
  }
  
  
  
  private func waitResponse() {
    let type = (request.isAsynchronous ? "asynchronous" : "synchronous")
    VK.Log.put(request, "Wait to \(type) response")
    _ = responseWaiter.wait(timeout: DispatchTime.distantFuture)
    VK.Log.put(request, "\(type) response is recieved")
    VK.Log.removeFromRequestsQueue(request)
  }
  
  
  
  private func finishConnection() {
    finishQueue.sync {
      guard self.canFinish else {return}
      self.canFinish = false
      self.timeoutOperation.cancel()
      self.request.response.execute()
      self.responseWaiter.signal()
    }
  }
  
  
  
  //MARK: - NSURLConnectionDataDelegate
  func connection(_ connection: NSURLConnection, didReceive data: Data) {
    VK.Log.put(request, "Connection received \(data.count) bytes. Total \(reqData.length) bytes")
    reqData.append(data)
  }
  
  
  
  func connectionDidFinishLoading(_ connection: NSURLConnection) {
    VK.Log.put(request, "Connection finished")
    request.response.create(reqData as Data)
    finishConnection()
  }
  
  
  
  func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
    let error = VK.Error(err: error as NSError, req: request!)
    VK.Log.put(request, "Connection failed with error: \(error)")
    request.response.setError(error)
    finishConnection()
  }
  
  
  
  func connection(_ connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    VK.Log.put(request, "Uploding file: \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
    request!.progressBlock(totalBytesWritten, totalBytesExpectedToWrite)
  }
  
  
  deinit {
    VK.Log.put(self.request, "DEINIT connection")
  }
}
