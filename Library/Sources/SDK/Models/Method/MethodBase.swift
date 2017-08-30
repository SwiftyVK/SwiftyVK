public protocol Sendable {
    @discardableResult
    func send(in session: Session?) -> Task
}

public extension Sendable {
    @discardableResult
    func send() -> Task {
        return send(in: nil)
    }
}

public protocol MethodBase: Sendable {
    func configure(with config: Config) -> SuccessableFailbaleMethod
    func onSuccess(_ clousure: @escaping (Data) -> ()) -> FailableConfigurableMethod
    func onError(_ clousure: @escaping (VKError) -> ()) -> SuccessableConfigurableMethod
    func send(in session: Session?) -> Task
}
