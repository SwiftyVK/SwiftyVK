import Foundation



internal final class SendQueue: OperationQueue {
    static let queue = SendQueue()
    
    private let addingQueue = DispatchQueue(label: "SwiftyVK.SendQueue")
    private let runLoopQueue = DispatchQueue(label: "SwiftyVK.runLoopQueue")

    private var apiCounter = 0
    private var waited = [SendTask]()
    
    override var description: String {
        return String(format: "[%d:%d]", apiCounter, waited.count)
    }
    
    
    private override init() {
        super.init()
        qualityOfService = .userInitiated
        maxConcurrentOperationCount = 1
        VK.Log.put("LifeCycle", "init \(self)")
        
        runLoopQueue.async {
            let timer = Timer(timeInterval: 1, target: self, selector: #selector(self.dropCounter), userInfo: nil, repeats: true)
            timer.tolerance = 0.05
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            CFRunLoopRun()
        }
    }
    
    
    
    override func addOperation(_ op: Operation) {
        super.addOperation(op)
    }
    
    
    
    func addApi(_ op: SendTask) {
        addingQueue.async {
            if !VK.config.useSendLimit || self.apiCounter < VK.config.sendLimit {
                self.apiCounter += 1
                VK.Log.put("SendQueue", "\(self) send \(op)")
                self.addOperation(op)
            } else {
                self.waited.append(op)
                VK.Log.put("SendQueue", "\(self) wait \(op)")
            }
        }
    }
    
    
    
    func addNotApi(_ op: SendTask) {
        VK.Log.put("SendQueue", "send free \(op)")
        addOperation(op)
    }
    
    
    
    @objc private func dropCounter() {
        addingQueue.async {
            guard !self.waited.isEmpty || self.apiCounter > 0 else {
                return
            }
            self.apiCounter = 0
            
            while !self.waited.isEmpty && self.apiCounter < VK.config.sendLimit {
                self.apiCounter += 1
                let op = self.waited.removeFirst()
                VK.Log.put("SendQueue", "\(self) send waited \(op)")
                self.addOperation(op)
            }
        }
    }
}
