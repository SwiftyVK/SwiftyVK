extension Methods {
    public final class SuccessableFailableProgressable: Basic, ChainableMethod {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressable {
            return withOnError(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailable {
            return withOnProgress(clousure)
        }
    }
    
    public final class SuccessableFailableConfigurable: Basic, ChainableMethod {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableConfigurable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableConfigurable {
            return withOnError(clousure)
        }
        
        public func configure(with config: Config) -> SuccessableFailable {
            return withConfig(config)
        }
    }
    
    public final class SuccessableProgressableConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> ProgressableConfigurable {
            return withOnSuccess(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableConfigurable {
            return withOnProgress(clousure)
        }
        
        public func configure(with config: Config) -> SuccessableProgressable {
            return withConfig(config)
        }
    }
    
    public final class FailableProgressableConfigurable: Basic {
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> ProgressableConfigurable {
            return withOnError(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> FailableConfigurable {
            return withOnProgress(clousure)
        }
        
        public func configure(with config: Config) -> FailableProgressable {
            return withConfig(config)
        }
    }
}
