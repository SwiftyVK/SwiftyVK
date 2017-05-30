import Foundation

/// Atomic container for any Equatable value. Synchronized with Lock.
class Atomic<Value> where Value: Equatable {
    
    private var value: Value
    private var lock = Lock()
    
    private var willWrap: ((Value) -> ())?
    private var didWrap: ((Value) -> ())?

    /// Init new atomic
    /// - parameter value: any Equatable value
    init(_ value: Value) {
        self.value = value
    }
    
    /// Wrap new value atomically
    /// - parameter newValue: any Equatable value
    func wrap(_ newValue: Value) {
        guard value != newValue else {return}
        
        lock.performCritical {
            let oldValue = value
            willWrap?(newValue)
            value = newValue
            didWrap?(oldValue)
        }
    }
    
    /// Set up clousure which will be execute before wrapping
    /// - parameter closure: clousure with oldValue
    func willWrap(_ closure: ((Value) -> ())?) {
        self.willWrap = closure
    }
    
    /// Set up clousure which will be execute after wrapping
    /// - parameter closure: clousure with newValue
    func didWrap(_ closure: ((Value) -> ())?) {
        self.didWrap = closure
    }
    
    /// Unwrap wrapped value atomically
    /// - returns: wrapped value
    func unwrap() -> Value {
        return lock.performCritical {
            return value
        }
    }
    
    /// Perform scope with wrapped value atomically
    /// - parameter scope: closure with some work on wrapped value
    func perform(scope: (Value) throws -> ()) rethrows {
        try lock.performCritical {
            try scope(value)
        }
    }
    
    /// Perform scope and modify wrapped value atomically
    /// - parameter scope: clousure whitch modify wrapped value
    func modify(withScope scope: (Value) throws -> Value) rethrows {
        try lock.performCritical {
            let oldValue = value
            let newValue = try scope(value)
            
            guard newValue != oldValue else {return}
            
            willWrap?(newValue)
            value = newValue
            didWrap?(oldValue)
        }
    }
}

infix operator |<
///atomic wrap operator
func |< <Value>(container: Atomic<Value>, value: Value) {
    container.wrap(value)
}

postfix operator |>
///atomic unwrap operator
postfix func |> <Value>(container: Atomic<Value>) -> Value {
    return container.unwrap()
}

infix operator <>
///atomic perform operator
func <> <Value>(container: Atomic<Value>, scope: (Value) throws -> ()) rethrows {
    return try container.perform(scope: scope)
}

infix operator ><
///atomic modify operator
func >< <Value>(container: Atomic<Value>, scope: (Value) throws -> Value) rethrows {
    return try container.modify(withScope: scope)
}
