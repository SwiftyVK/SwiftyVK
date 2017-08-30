public final class SuccessableMethod: SendableMethod {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> Sendable {
        callbacks.onSuccess = clousure
        return SendableMethod(method, config, callbacks)
    }
}

public final class FailableMethod: SendableMethod {
    public func onError(_ clousure: @escaping (VKError) -> ()) -> Sendable {
        callbacks.onError = clousure
        return SendableMethod(method, config, callbacks)
    }
}

public final class ConfigurableMethod: SendableMethod {
    public func configure(with config: Config) -> Sendable {
        return SendableMethod(method, config, callbacks)
    }
}
