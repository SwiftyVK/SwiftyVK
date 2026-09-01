extension Methods {
    public final class SuccessableFailable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Failable {
            withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Successable {
            withOnError(clousure)
        }
    }
    
    public final class SuccessableProgressable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Progressable {
            withOnSuccess(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Successable {
            withOnProgress(clousure)
        }
    }
    
    public final class SuccessableConfigurable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Configurable {
            withOnSuccess(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Successable {
            withConfig(config)
        }
    }
    
    public final class FailableConfigurable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Configurable {
            withOnError(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Failable {
            withConfig(config)
        }
    }
    
    public final class FailableProgressable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Progressable {
            withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Failable {
            withOnProgress(clousure)
        }
    }
    
    public final class ProgressableConfigurable: Basic {
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Configurable {
            withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Progressable {
            withConfig(config)
        }
    }
}
