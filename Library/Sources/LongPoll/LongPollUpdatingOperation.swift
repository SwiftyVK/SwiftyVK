//import Foundation
//
//final class LongPollUpdatingOperation: Operation {
//    
//    private let server: String
//    private var startTs: String
//    private let lpKey: String
//    private let onResponse: ([JSON]?) -> ()
//    private let onKeyExpired: () -> ()
//    private var currentRequest: RequestExecution?
//    
//    override var isFinished: Bool {
//        return canFinish
//    }
//    
//    private var canFinish = false {
//        willSet {
//            willChangeValue(forKey: "isFinished")
//        }
//        didSet {
//            didChangeValue(forKey: "isFinished")
//        }
//    }
//    
//    private override init() {
//        fatalError()
//    }
//    
//    init(
//        server: String,
//        lpKey: String,
//        startTs: String,
//        onResponse: @escaping ([JSON]?) -> (),
//        onKeyExpired: @escaping () -> ()
//        ) {
//        VK.Log.put("LongPoll", "Init op")
//
//        self.server = server
//        self.lpKey = lpKey
//        self.startTs = startTs
//        self.onResponse = onResponse
//        self.onKeyExpired = onKeyExpired
//    }
//    
//    override func main() {
//        update(ts: startTs)
//    }
//    
//    private func update(ts: String) {
//        guard !isCancelled else { return }
//        
//        var req = RequestConfig(url: "https://\(server)?act=a_check&key=\(lpKey)&ts=\(ts)&wait=25&mode=106")
//        req.catchErrors = false
//        req.timeout = 30
//        req.maxAttempts = 1
//        
//        VK.Log.put("LongPoll", "Send with \(req)")
//        
//        currentRequest = req.send(
//            onSuccess: { [weak self] response in
//                guard let `self` = self else { return }
//                guard !self.isCancelled else { return }
//                
//                VK.Log.put("LongPoll", "Received response with \(req)")
//                
//                if response["failed"].intValue > 0 {
//                    self.onKeyExpired()
//                    self.canFinish = true
//                }
//                else {
//                    let newTs = response["ts"].stringValue
//                    self.onResponse(response["updates"].array)
//                    self.update(ts: newTs)
//                }
//            },
//            onError: { [weak self] _ in
//                guard let `self` = self else { return }
//                guard !self.isCancelled else {
//                    return
//                }
//                VK.Log.put("LongPoll", "Received error with \(req)")
//                Thread.sleep(forTimeInterval: 3)
//                guard !self.isCancelled else { return }
//                self.update(ts: ts)
//            }
//        )
//    }
//    
//    override func cancel() {
//        super.cancel()
//        currentRequest?.cancel()
//        canFinish = true
//    }
//}
