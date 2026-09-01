extension Methods {
    public final class SuccessableFailableProgressable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressable {
            withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressable {
            withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailable {
            withOnProgress(clousure)
        }
    }
    
    public final class SuccessableFailableConfigurable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableConfigurable {
            withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableConfigurable {
            withOnError(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> SuccessableFailable {
            withConfig(config)
        }
    }
    
    public final class SuccessableProgressableConfigurable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> ProgressableConfigurable {
            withOnSuccess(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableConfigurable {
            withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> SuccessableProgressable {
            withConfig(config)
        }
    }
    
    public final class FailableProgressableConfigurable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> ProgressableConfigurable {
            withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> FailableConfigurable {
            withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> FailableProgressable {
            withConfig(config)
        }
    }
}
