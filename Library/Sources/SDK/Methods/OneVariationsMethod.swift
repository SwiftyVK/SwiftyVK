extension Methods {
    public final class Successable: Basic {
        public func onSuccess(_ clousure: @escaping Callbacks.Success) -> Basic {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
    }
    
    public final class Failable: Basic {
        public func onError(_ clousure: @escaping Callbacks.Error) -> Basic {
            request.callbacks.onError = clousure
            return .init(request)
        }
    }
    
    public final class Configurable: Basic {
        public func configure(with config: Config) -> Basic {
            request.config = config
            return .init(request)
        }
    }
}
