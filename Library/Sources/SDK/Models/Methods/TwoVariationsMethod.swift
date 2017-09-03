extension Methods {
    public final class SuccessableFailbale: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Failable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Successable {
            return withOnError(clousure)
        }
    }
    
    public final class SuccessableProgressable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Progressable {
            return withOnSuccess(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Successable {
            return withOnProgress(clousure)
        }
    }
    
    public final class SuccessableConfigurable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Configurable {
            return withOnSuccess(clousure)
        }
        
        public func configure(with config: Config) -> Successable {
            return withConfig(config)
        }
    }
    
    public final class FailableConfigurable: Basic {
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Configurable {
            return withOnError(clousure)
        }
        
        public func configure(with config: Config) -> Failable {
            return withConfig(config)
        }
    }
    
    public final class FailableProgressable: Basic {
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Progressable {
            return withOnError(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Failable {
            return withOnProgress(clousure)
        }
    }
    
    public final class ProgressableConfigurable: Basic {
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Configurable {
            return withOnProgress(clousure)
        }
        
        public func configure(with config: Config) -> Progressable {
            return withConfig(config)
        }
    }
}
