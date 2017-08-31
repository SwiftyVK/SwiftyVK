extension Methods {
    public final class SuccessableFailbaleProgressable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressable {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressable {
            request.callbacks.onError = clousure
            return .init(request)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailbale {
            request.callbacks.onProgress = clousure
            return .init(request)
        }
    }
    
    public final class SuccessableFailbaleConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableConfigurable {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableConfigurable {
            request.callbacks.onError = clousure
            return .init(request)
        }
        
        public func configure(with config: Config) -> SuccessableFailbale {
            request.config = config
            return .init(request)
        }
    }
    
    public final class SuccessableProgressableConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> ProgressableConfigurable {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableConfigurable {
            request.callbacks.onProgress = clousure
            return .init(request)
        }
        
        public func configure(with config: Config) -> SuccessableProgressable {
            request.config = config
            return .init(request)
        }
    }
    
    public final class FailbaleProgressableConfigurable: Basic {
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> ProgressableConfigurable {
            request.callbacks.onError = clousure
            return .init(request)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> FailableConfigurable {
            request.callbacks.onProgress = clousure
            return .init(request)
        }
        
        public func configure(with config: Config) -> FailableProgressable {
            request.config = config
            return .init(request)
        }
    }
}
