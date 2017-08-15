import Foundation

class Lock {
    
    private var unfairLock: os_unfair_lock_s?
    private var spinLock: Int32?
    
    init() {
        if #available(OSX 10.12, *, iOS 10, *, tvOS 10.0, *) {
            unfairLock = os_unfair_lock_s()
        }
        else {
            spinLock = OS_SPINLOCK_INIT
        }
    }
    
    func lock() {
        if #available(OSX 10.12, *, iOS 10, *, tvOS 10.0, *) {
            os_unfair_lock_lock(&unfairLock!)
        }
        else {
            OSSpinLockLock(&spinLock!)
        }
    }
    
    func unlock() {
        if #available(OSX 10.12, *, iOS 10, *, tvOS 10.0, *) {
            os_unfair_lock_unlock(&unfairLock!)
        }
        else {
            OSSpinLockUnlock(&spinLock!)
        }
    }
    
    func performCritical<T> (scope: () throws -> (T)) rethrows -> T {
        lock()
        defer {unlock()}
        return try scope()
    }
}
