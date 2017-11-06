protocol VKReachability {
    var isReachable: Bool { get }

    func startNotifier() throws
    func waitForReachable(onWait: (() -> ()))
    func stopWaitForReachable()
}

extension VKReachability {
    func waitForReachable() {
        waitForReachable(onWait: {})
    }
}

extension Reachability: VKReachability {
    
    func waitForReachable(onWait: (() -> ())) {
        guard !isReachable else { return }
        
        whenReachable = { [weak self] _ in
            self?.semaphore.signal()
        }
        
        do {
            try startNotifier()
            onWait()
            semaphore.wait()
        }
        catch {}
        
        whenReachable = nil
    }
    
    func stopWaitForReachable() {
        semaphore.signal()
    }
}
