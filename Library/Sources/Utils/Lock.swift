import Foundation

protocol Lock {
    func lock()
    func unlock()
}

extension Lock {
    @discardableResult
    func perform<T> (scope: () throws -> (T)) rethrows -> T {
        lock()
        defer { unlock() }
        return try scope()
    }
}

final class MultiplatrormLock: Lock {
    private let lockRef: Lock
    
    init() {
        lockRef = UnfairLock()
    }
    
    func lock() {
        lockRef.lock()
    }
    
    func unlock() {
        lockRef.unlock()
    }
}

final class UnfairLock: Lock {
    var lockRer = os_unfair_lock_s()
    
    func lock() {
        os_unfair_lock_lock(&lockRer)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&lockRer)
    }
}
