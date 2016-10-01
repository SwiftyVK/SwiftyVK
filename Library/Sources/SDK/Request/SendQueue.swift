import Foundation



final class SendQueue : OperationQueue {
    static let queue = SendQueue()
    
    private let addingQueue = DispatchQueue(label: "SwiftyVK.SendQueue.addingQueue")
    private var apiCounter = 0
    private var queued = [SendOperation]()
    
    
    
    private override init() {
        super.init()
        DispatchQueue.global(qos: .background).async {
            let timer = Timer(timeInterval: 1, target: self, selector: #selector(self.dropCounter), userInfo: nil, repeats: true)
            timer.tolerance = 0.1
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            CFRunLoopRun()
        }
    }
    
    
    
    override func addOperation(_ op: Operation) {}
    
    
    
    func addApi(_ op: SendOperation) {
        addingQueue.async {
            if !VK.defaults.useSendLimit || self.apiCounter < VK.defaults.sendLimit {
                self.apiCounter += 1
                super.addOperation(op)
//                print("INCREASE COUNTER: \(self.apiCounter)")
            }
            else {
                self.queued.append(op)
//                print("INCREASE QUEUED: \(self.queued.count)")
            }
        }
    }
    
    
    
    func addNotApi(_ op: SendOperation) {
        self.addOperation(op)
    }
    
    
    
    @objc private func dropCounter() {
        addingQueue.async {
            guard self.apiCounter > 0 else {return}
            self.apiCounter = 0
            
            while !self.queued.isEmpty && self.apiCounter < VK.defaults.sendLimit {
                self.apiCounter += 1
                super.addOperation(self.queued.removeFirst())
//                print("DICREASE QUEUED: \(self.queued.count), COUNTER: \(self.apiCounter)")
            }
//            print("OPERATIONS: \(super.operations.count)")
        }
    }
}
