public protocol Method: SendableMethod {
    func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Methods.FailbaleProgressableConfigurable
    func onError(_ clousure: @escaping RequestCallbacks.Error) -> Methods.SuccessableProgressableConfigurable
    func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Methods.SuccessableFailbaleConfigurable
    func configure(with config: Config) -> Methods.SuccessableFailbaleProgressable
}

public protocol SendableMethod {
    func toRequest() -> Request
}

public extension SendableMethod {
    @discardableResult
    func send() -> Task {
        return send(in: nil)
    }
    
    @discardableResult
    func send(in session: Session?) -> Task {
        guard let session = session ?? VK.sessions?.default else {
            fatalError("You must call VK.prepareForUse function to start using SwiftyVK!")
        }
        
        return session.send(method: self)
    }
}

public struct Methods {}
