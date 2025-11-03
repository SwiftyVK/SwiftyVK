import Foundation

final class AttemptApiQueue: OperationQueue, @unchecked Sendable {
    
    var limit: AttemptLimit
    
    private let counterQueue = DispatchQueue(label: "SwiftyVK.counterQueue", qos: .userInitiated)
    private let gateQueue = DispatchQueue(label: "SwiftyVK.attemptApi.gateQueue", qos: .userInitiated)
    
    private var sent = 0
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
        
        if limit.count < 1 || sent < limit.count {
            super.addOperation(operation)
            sent += 1
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
        
        let oldSent = sent
        sent = 0
        
        guard oldSent > 0 else { return }
        
        while sent < limit.count && !waited.isEmpty {
            sent += 1
            let op = waited.removeFirst()
            super.addOperation(op)
        }
    }
}
