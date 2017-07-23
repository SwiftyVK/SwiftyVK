import Foundation

final class LongPollUpdatingOperation: Operation {
    
    private let server: String
    private var startTs: String
    private let lpKey: String
    private let onResponse: (String, [JSON]?) -> ()
    private let onError: () -> ()
    private let onKeyExpired: () -> ()
    
    override var isFinished: Bool {
        return reallyFinished
    }
    
    private var reallyFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private override init() {
        fatalError()
    }
    
    init(
        server: String,
        lpKey: String,
        startTs: String,
        onResponse: @escaping (String, [JSON]?) -> (),
        onError: @escaping () -> (),
        onKeyExpired: @escaping () -> ()
        ) {
        self.server = server
        self.lpKey = lpKey
        self.startTs = startTs
        self.onResponse = onResponse
        self.onError = onError
        self.onKeyExpired = onKeyExpired
    }
    
    override func main() {
        update(ts: startTs)
    }
    
    private func update(ts: String) {
        guard !isCancelled else {return}
        
        var req = RequestConfig(url: "https://\(server)?act=a_check&key=\(lpKey)&ts=\(ts)&wait=25&mode=106")
        req.catchErrors = false
        req.timeout = 30
        req.maxAttempts = 1
        
        VK.Log.put("LongPoll", "Send with \(req)")
        
        req.send(
            onSuccess: { [weak self] response in
                guard let `self` = self else { return }
                guard !self.isCancelled else { return }
                
                VK.Log.put("LongPoll", "Received response with \(req)")
                
                if response["failed"].intValue > 0 {
                    self.onKeyExpired()
                    self.reallyFinished = true
                } else {
                    let newTs = response["ts"].stringValue
                    self.onResponse(newTs, response["updates"].array)
                    self.update(ts: newTs)
                }
            },
            onError: { [weak self] _ in
                guard let `self` = self else { return }
                guard !self.isCancelled else { return }
                
                VK.Log.put("LongPoll", "Received error with \(req)")
                
                self.onError()
                self.reallyFinished = true
            }
        )
    }
}
