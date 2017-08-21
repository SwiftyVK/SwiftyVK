@testable import SwiftyVK

class URLSessionTaskMock: VKURLSessionTask {
    
    var state = "initial"
    
    var countOfBytesReceived: Int64 = 0
    var countOfBytesSent: Int64 = 0
    var countOfBytesExpectedToSend: Int64 = 0
    var countOfBytesExpectedToReceive: Int64 = 0
    
    func resume() {
        state = "running"
    }
    
    func cancel() {
        state = "cancelled"
    }
    
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        
    }
    
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        
    }
    
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?) {
        
    }
}
