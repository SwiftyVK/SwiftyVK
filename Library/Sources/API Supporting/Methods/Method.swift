import Foundation

/// Protocol constraint which allows send request
public protocol SendableMethod {
    /// For internal using only
    func toRequest() -> Request
}

extension SendableMethod {
    
    /// Shedule request to sending
    @discardableResult
    public func send() -> Task {
        return send(in: VK.sessions.default)
    }
    
    @discardableResult
    func send(in session: Session) -> Task {
        return session.send(method: self)
    }
    
    /// Returns convert request to synchronously version.
    public func synchronously() -> SynchronouslyTask {
        return SynchronouslyTask(request: toRequest())
    }
}

/// Protocol constraint which allows build chains of requests
public protocol ChainableMethod: SendableMethod {}

public protocol Method: ChainableMethod {}

extension Method {
    /// Set onSuccess callback
    /// - parameter clousure: callback which will be executed when request is successfully sended
    public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Methods.FailableConfigurable {
        let request = toRequest()
        request.callbacks.onSuccess = clousure
        return .init(request)
    }
    
    /// Set onError callback
    /// - parameter clousure: callback which will be executed when request is failed
    public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Methods.SuccessableConfigurable {
        let request = toRequest()
        request.callbacks.onError = clousure
        return .init(request)
    }
    
    /// Set values which override session configuration for this request
    /// - parameter config: new request config
    public func configure(with config: Config) -> Methods.SuccessableFailable {
        let request = toRequest()
        request.config = config
        return .init(request)
    }
    
    /// Build chain of requests
    /// - parameter next: Clousure which recieve result of executing previos request
    /// and return next request
    public func chain(_ next: @escaping (Data) throws -> ChainableMethod) -> Methods.SuccessableFailableConfigurable {
        let request = toRequest()
        request.add(next: next)
        return .init(request)
    }
}

public struct Methods {}
