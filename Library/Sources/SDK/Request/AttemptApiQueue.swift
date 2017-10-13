class AttemptApiQueue: OperationQueue {
    
    var limit: AttemptLimit
    
    private let counterQueue = DispatchQueue(label: "SwiftyVK.counterQueue", qos: .userInitiated)
    private let gateQueue = DispatchQueue(label: "SwiftyVK.attemptApi.gateQueue", qos: .userInitiated)
    
    private var sended = 0
    private var waited = [Operation]()
    private var timer: Timer?
    private let lock = MultiplatrormLock()
    
    init(limit: AttemptLimit) {
        self.limit = limit
        
        super.init()
    }
    
    func killTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func runTimer() {
        let timer = Timer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.dropCounter),
            userInfo: nil,
            repeats: true
        )
        
        self.timer = timer
        
        counterQueue.async {
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            RunLoop.current.run()
        }
    }
    
    override func addOperation(_ operation: Operation) {
        gateQueue.async { [weak self] in
            self?.lock.perform { self?._addOperation(operation) }
        }
    }
    
    private func _addOperation(_ operation: Operation) {
        if timer == nil {
            runTimer()
        }
        
        if limit.count < 1 || sended < limit.count {
            super.addOperation(operation)
            sended += 1
        }
        else {
            waited.append(operation)
        }
    }
    
    @objc
    private func dropCounter() {
        gateQueue.async { [weak self] in
            _ = self?.lock.perform { self?._dropCounter() }
        }
    }
    
    private func _dropCounter() {
        guard !waited.isEmpty else {
            killTimer()
            return
        }
        
        guard sended > 0 else { return }
        
        sended = 0
        
        while !waited.isEmpty && sended < limit.count {
            sended += 1
            let op = waited.removeFirst()
            super.addOperation(op)
        }
    }
}
