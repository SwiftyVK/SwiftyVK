public final class SuccessableMethod: MethodInstance {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> SendableMethod {
        request.callbacks.onSuccess = clousure
        return MethodInstance(request)
    }
}

public final class FailableMethod: MethodInstance {
    public func onError(_ clousure: @escaping (VKError) -> ()) -> SendableMethod {
        request.callbacks.onError = clousure
        return MethodInstance(request)
    }
}

public final class ConfigurableMethod: MethodInstance {
    public func configure(with config: Config) -> SendableMethod {
        request.config = config
        return MethodInstance(request)
    }
}
