extension Methods {
    public final class SuccessableFailbaleProgressable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressable {
            return withOnError(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailbale {
            return withOnProgress(clousure)
        }
    }
    
    public final class SuccessableFailbaleConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableConfigurable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableConfigurable {
            return withOnError(clousure)
        }
        
        public func configure(with config: Config) -> SuccessableFailbale {
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
    
    public final class FailbaleProgressableConfigurable: Basic {
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
