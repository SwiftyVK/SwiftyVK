extension Methods {
    public final class SuccessableFailbale: Basic {
        public func onSuccess(_ clousure: @escaping (Data) -> ()) -> Failable {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        public func onError(_ clousure: @escaping (VKError) -> ()) -> Successable {
            request.callbacks.onError = clousure
            return .init(request)
        }
    }
    
    public final class SuccessableConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping (Data) -> ()) -> Configurable {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        public func configure(with config: Config) -> Successable {
            request.config = config
            return .init(request)
        }
    }
    
    public final class FailableConfigurable: Basic {
        public func onError(_ clousure: @escaping (VKError) -> ()) -> Configurable {
            request.callbacks.onError = clousure
            return .init(request)
        }
        
        public func configure(with config: Config) -> Failable {
            request.config = config
            return .init(request)
        }
    }
}
