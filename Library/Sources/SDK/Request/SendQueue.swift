import Foundation



internal final class SendQueue: OperationQueue {
    static let queue = SendQueue()

    private let addingQueue = DispatchQueue(label: "SwiftyVK.addingQueue")
    private let notApiQueue = DispatchQueue(label: "SwiftyVK.notApiQueue")
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
    


    func add(task op: SendTask, api: Bool) {
        
        guard api else {
            notApiQueue.async {
                VK.Log.put("SendQueue", "send free \(op)")
                op.start()
            }
            
            return
        }
        
        addingQueue.async {
            if !VK.config.useSendLimit || self.apiCounter < VK.config.sendLimit {
                self.apiCounter += 1
                VK.Log.put("SendQueue", "\(self) send \(op)")
                self.addOperation(op)
            }
            else {
                self.waited.append(op)
                VK.Log.put("SendQueue", "\(self) wait \(op)")
            }
        }
    }



    @objc
    private func dropCounter() {
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
