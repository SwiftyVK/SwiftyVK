@testable import SwiftyVK

@objc class URLSessionTaskMock: NSObject, VKURLSessionTask {
    
    var countOfBytesReceived: Int64 = 0
    var countOfBytesSent: Int64 = 0
    var countOfBytesExpectedToSend: Int64 = 0
    var countOfBytesExpectedToReceive: Int64 = 0
    
    var onResume: (() -> ())?
    
    func resume() {
        onResume?()
    }
    
    var onCancel: (() -> ())?
    
    func cancel() {
        onCancel?()
    }
    
    var onAddObserver: ((NSObject, String, NSKeyValueObservingOptions, UnsafeMutableRawPointer?) -> ())?

    override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        onAddObserver?(observer, keyPath, options, context)
    }
    
    var onRemoveObserver: ((NSObject, String) -> ())?
    
    override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        onRemoveObserver?(observer, keyPath)
    }
    
    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        return true
    }
}
