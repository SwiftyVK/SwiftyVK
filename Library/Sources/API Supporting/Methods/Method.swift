public protocol SendableMethod {
    func toRequest() -> Request
}

extension SendableMethod {
    
    @discardableResult
    public func send() -> Task {
        guard let session = VK.sessions?.default else {
            fatalError("You must call VK.setUp function to start using SwiftyVK!")
        }
        
        return send(in: session)
    }
    
    @discardableResult
    func send(in session: Session) -> Task {
        return session.send(method: self)
    }
}

public protocol ChainableMethod: SendableMethod {}

public protocol Method: ChainableMethod {}

extension Method {
    public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Methods.FailableConfigurable {
        let request = toRequest()
        request.callbacks.onSuccess = clousure
        return .init(request)
    }
    
    public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Methods.SuccessableConfigurable {
        let request = toRequest()
        request.callbacks.onError = clousure
        return .init(request)
    }
    
    public func configure(with config: Config) -> Methods.SuccessableFailable {
        let request = toRequest()
        request.config = config
        return .init(request)
    }
    
    public func chain(_ next: @escaping (Data) throws -> ChainableMethod) -> Methods.SuccessableFailableConfigurable {
        let request = toRequest()
        request.add(next: next)
        return .init(request)
    }
}

public struct Methods {}
