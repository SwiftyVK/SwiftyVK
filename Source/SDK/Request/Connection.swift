import Foundation



private let requestsQueue = dispatch_queue_create("com.VK.requestsQueue", DISPATCH_QUEUE_SERIAL)
private let loopsQueue = dispatch_queue_create("com.VK.loopsQueue", DISPATCH_QUEUE_CONCURRENT)



internal class Connection : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
  private var request : Request!
  private lazy var reqData = NSMutableData()
  private lazy var responseWaitSemaphore = dispatch_semaphore_create(0)
  
  
  
  
  internal class func sendInCurrentThread(request: Request) {
    Log([.connection], "Send request: \(self) in parents thread")
    
    if request.isAPI {
      dispatch_async(requestsQueue, {
        Log([.APIBlock], "API locked")
        NSThread.sleepForTimeInterval(VK.defaults.sleepTime)
        Log([.APIBlock], "API unlocked")
      })
    }
    
    request.response.error = nil
    
    do {
      request.response.create(try NSURLConnection.sendSynchronousRequest(request.URLRequest, returningResponse: nil))
    }
    catch let error as NSError {
      request.response.error = VK.Error(ns: error, req: nil)
    }
    
    handleResponse(request.response)
  }
  
  
  
  
  init?(request: Request) {
    assert(!(!request.isAsynchronous && NSThread.isMainThread() && request.catchErrors), "\n\nWe turned off the ability to send synchronous requests with catchErrors on the main thread, as it may cause a lot of non-obvious, subtle bugs. \nPlease send synchronous requests with catchErrors from other threads, or use catchErrors = false (not recommend). \nThank you for your understanding and good luck in the use SwiftyVK.\n\n")
    
    self.request = request
    super.init()
    dispatch_async(request.isAPI ? requestsQueue : loopsQueue, {
      request.isAPI ? Log([.APIBlock], "API locked") : ()
      
      dispatch_async(loopsQueue, {
        _ = NSURLConnection(request: request.URLRequest, delegate: self, startImmediately: true)
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: NSTimeInterval(Double(request.timeout)*1.5)))
      })
      
      if request.isAPI {
        NSThread.sleepForTimeInterval(VK.defaults.sleepTime)
        Log([.APIBlock], "API unlocked")
      }
    })
    
    if request.isAsynchronous == false {
      Log([LogOption.thread], "Waiting for synchronous response")
      dispatch_semaphore_wait(responseWaitSemaphore, DISPATCH_TIME_FOREVER)
      Log([LogOption.thread], "Waiting for synchronous response complete")
    }
  }
  
  
  
  private func finishConnection() {
    Connection.handleResponse(request!.response)
    dispatch_semaphore_signal(responseWaitSemaphore)
  }
  
  
  
  private class func handleResponse(response: Response) {
    if let error = response.error {
      if response.request!.catchErrors {
        response.error?.`catch`()
      }
      else if response.request?.isCanSend == true {
        response.error = nil
        response.request?.reSend()
      }
      else {
        response.request?.isAPI == true ? Log([LogOption.thread], "Executing error block") : ()
        response.request?.errorBlock(error: error)
        response.request?.isAPI == true ? Log([LogOption.thread], "Executing error block is complete") : ()
      }
    }
    else if let responseValue = response.success {
      response.request?.isAPI == true ? Log([LogOption.thread], "Executing success block") : ()
      response.request?.successBlock(response: responseValue)
      response.request?.isAPI == true ? Log([LogOption.thread], "Executing success block is complete") : ()
    }
    
    response.error = nil
    response.success = nil
  }
  
  
  
  //MARK: - NSURLConnectionDataDelegate
  func connection(connection: NSURLConnection, didReceiveData data: NSData) {
    Log([.connection], "Received \(data.length) bytes")
    reqData.appendData(data)
  }
  
  
  
  func connectionDidFinishLoading(connection: NSURLConnection) {
    Log([.connection], "Downloading is complete. Received \(reqData.length) bytes")
    request.response.create(reqData)
    finishConnection()
  }
  
  
  
  func connection(connection: NSURLConnection, didFailWithError error: NSError)  {
    Log([.connection], "Connection failed with error: \n\(error)")
    request.response.error = VK.Error(ns: error, req: request!)
    finishConnection()
  }
  
  
  
  func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    dispatch_async(dispatch_get_main_queue(), {
      Log([.upload], "Uploding file: \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
      Log([.thread], "Executing progress block")
      self.request!.progressBlock(done: totalBytesWritten, total: totalBytesExpectedToWrite)
      Log([.thread], "Executing progress block is complete")
    })
  }
}