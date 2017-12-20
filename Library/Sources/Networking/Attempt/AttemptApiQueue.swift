final class AttemptApiQueue: OperationQueue {
    
    var limit: AttemptLimit
    
    private let counterQueue = DispatchQueue(label: "SwiftyVK.counterQueue", qos: .userInitiated)
    private let gateQueue = DispatchQueue(label: "SwiftyVK.attemptApi.gateQueue", qos: .userInitiated)
    
    private var sended = 0
    private var waited = [Operation]()
    private var dropCounterTimer: DispatchSourceTimer?
    
    init(limit: AttemptLimit) {
        self.limit = limit
        super.init()
    }
    
    private func runDropCounterTimer() {
        dropCounterTimer = DispatchSource.makeTimerSource(queue: counterQueue)
        dropCounterTimer?.schedule(wallDeadline: .now() + 1, repeating: 1)
        dropCounterTimer?.setEventHandler { [weak self] in
            self?.dropCounter()
        }
        
        dropCounterTimer?.resume()
    }
    
    override func addOperation(_ operation: Operation) {
        gateQueue.async { [weak self] in
            self?._addOperation(operation)
        }
    }
    
    private func _addOperation(_ operation: Operation) {
        
        // swiftlint:disable empty_count next
        if dropCounterTimer == nil && (limit.count > 0 || !waited.isEmpty) {
            runDropCounterTimer()
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
            self?._dropCounter()
        }
    }
    
    private func _dropCounter() {
        
        defer {
            if waited.isEmpty {
                dropCounterTimer = nil
            }
        }
        
        let oldSended = sended
        sended = 0
        
        guard oldSended > 0 else { return }
        
        while sended < limit.count && !waited.isEmpty {
            sended += 1
            let op = waited.removeFirst()
            super.addOperation(op)
        }
    }
}
