public final class SuccessableFailbaleMethod: SendableMethod {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> FailableMethod {
        callbacks.onSuccess = clousure
        return FailableMethod(method, config, callbacks)
    }
    
    public func onError(_ clousure: @escaping (VKError) -> ()) -> SuccessableMethod {
        callbacks.onError = clousure
        return SuccessableMethod(method, config, callbacks)
    }
}

public final class SuccessableConfigurableMethod: SendableMethod {
    public func onSuccess(_ clousure: @escaping (Data) -> ()) -> ConfigurableMethod {
        callbacks.onSuccess = clousure
        return ConfigurableMethod(method, config, callbacks)
    }
    
    public func configure(with config: Config) -> SuccessableMethod {
        return SuccessableMethod(method, config, callbacks)
    }
}

public final class FailableConfigurableMethod: SendableMethod {
    public func onError(_ clousure: @escaping (VKError) -> ()) -> ConfigurableMethod {
        callbacks.onError = clousure
        return ConfigurableMethod(method, config, callbacks)
    }
    
    public func configure(with config: Config) -> FailableMethod {
        return FailableMethod(method, config, callbacks)
    }
}
