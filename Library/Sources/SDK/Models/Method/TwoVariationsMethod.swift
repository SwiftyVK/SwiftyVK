public final class SuccessableFailbaleMethod: MethodInstance {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> FailableMethod {
        request.callbacks.onSuccess = clousure
        return FailableMethod(request)
    }
    
    public func onError(_ clousure: @escaping (VKError) -> ()) -> SuccessableMethod {
        request.callbacks.onError = clousure
        return SuccessableMethod(request)
    }
}

public final class SuccessableConfigurableMethod: MethodInstance {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> ConfigurableMethod {
        request.callbacks.onSuccess = clousure
        return ConfigurableMethod(request)
    }
    
    public func configure(with config: Config) -> SuccessableMethod {
        request.config = config
        return SuccessableMethod(request)
    }
}

public final class FailableConfigurableMethod: MethodInstance {
    public func onError(_ clousure: @escaping (VKError) -> ()) -> ConfigurableMethod {
        request.callbacks.onError = clousure
        return ConfigurableMethod(request)
    }
    
    public func configure(with config: Config) -> FailableMethod {
        request.config = config
        return FailableMethod(request)
    }
}
