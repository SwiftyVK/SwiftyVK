import Foundation



internal final class SendQueue: OperationQueue {
    static let queue = SendQueue()

    private let orderedSendQueue = DispatchQueue(label: "SwiftyVK.orderedSendQueue")
    private let unorderedSendQueue = DispatchQueue(label: "SwiftyVK.unorderedSendQueue", attributes: .concurrent)
    private let dropCouterQueue = DispatchQueue(label: "SwiftyVK.dropCouterQueue")

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

        dropCouterQueue.async {
            let timer = Timer(timeInterval: 1, target: self, selector: #selector(self.dropCounter), userInfo: nil, repeats: true)
            timer.tolerance = 0.01
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            CFRunLoopRun()
        }
    }
    


    func add(task: SendTask, api: Bool) {
        VK.config.useSendLimit && api
            ? sendOrdered(task: task)
            : sendUnordered(task: task)
    }
    
    
    
    private func sendUnordered(task: SendTask) {
        unorderedSendQueue.async {
            VK.Log.put("SendQueue", "send free \(task)")
            task.start()
        }
    }
    
    
    
    private func sendOrdered(task: SendTask) {
        orderedSendQueue.async {
            if !VK.config.useSendLimit || self.apiCounter < VK.config.sendLimit {
                self.apiCounter += 1
                VK.Log.put("SendQueue", "\(self) send \(task)")
                self.addOperation(task)
            }
            else {
                self.waited.append(task)
                VK.Log.put("SendQueue", "\(self) wait \(task)")
            }
        }
    }



    @objc
    private func dropCounter() {
        orderedSendQueue.async {
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
