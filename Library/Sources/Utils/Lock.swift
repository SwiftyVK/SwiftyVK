import Foundation

protocol Lock {
    func lock()
    func unlock()
}

extension Lock {
    func perform<T> (scope: () throws -> (T)) rethrows -> T {
        lock()
        defer { unlock() }
        return try scope()
    }
}

class MultiplatrormLock: Lock {
    private let lockRef: Lock
    
    init() {
        if #available(OSX 10.12, *, iOS 10, *, tvOS 10.0, *) {
            lockRef = UnfairLock()
        }
        else {
            lockRef = SpinLock()
        }
    }
    
    func lock() {
        lockRef.lock()
    }
    
    func unlock() {
        lockRef.unlock()
    }
}

class SpinLock: Lock {
    private var lockRef = OS_SPINLOCK_INIT
    
    func lock() {
        OSSpinLockLock(&lockRef)
    }
    
    func unlock() {
        OSSpinLockUnlock(&lockRef)
    }
}

@available(OSX 10.12, *, iOS 10, *, tvOS 10.0, *)
class UnfairLock: Lock {
    var lockRer = os_unfair_lock_s()
    
    func lock() {
        os_unfair_lock_lock(&lockRer)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&lockRer)
    }
}
