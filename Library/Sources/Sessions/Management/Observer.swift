final class ParameterizedObserver<T> {
    
    private var containers = Set<Weak<T>>()
    
    func subscribe(_ object: AnyObject, handler: @escaping (T) -> ()) {
        let container = Weak<T>(disposable: object, handler: handler)
        
        guard !containers.contains(container) else {
            assertionFailure("Observer for this disposable already exists")
            return
        }
        
        containers.insert(container)
    }
    
    func unsubscribe(_ object: AnyObject) {
        containers.remove(Weak<T>(disposable: object))
    }
    
    func notify(with object: T) {
        var disposables = [AnyObject]()
        var handlers = [(T) -> ()]()
        
        disposables = containers.compactMap { $0.disposable }
        containers = containers.filter { $0.disposable != nil }
        handlers = containers.compactMap { $0.handler }
        
        withExtendedLifetime(disposables) {
            handlers.forEach { $0(object) }
        }
    }
}

private class Weak<T>: Hashable {
    weak var disposable: AnyObject?
    private(set) var handler: ((T) -> ())?
    
    init(disposable: AnyObject, handler: @escaping (T) -> ()) {
        self.disposable = disposable
        self.handler = handler
    }
    
    init(disposable: AnyObject) {
        self.disposable = disposable
    }
    
    var hashValue: Int {
        if let disposable = disposable { return ObjectIdentifier(disposable).hashValue }
        return 0
    }
    
    static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.disposable === rhs.disposable
    }
}
