extension Methods {
    public final class SuccessableFailableProgressable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressable {
            return withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressable {
            return withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailable {
            return withOnProgress(clousure)
        }
    }
    
    public final class SuccessableFailableConfigurable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableConfigurable {
            return withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableConfigurable {
            return withOnError(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> SuccessableFailable {
            return withConfig(config)
        }
    }
    
    public final class SuccessableProgressableConfigurable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> ProgressableConfigurable {
            return withOnSuccess(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableConfigurable {
            return withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> SuccessableProgressable {
            return withConfig(config)
        }
    }
    
    public final class FailableProgressableConfigurable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> ProgressableConfigurable {
            return withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> FailableConfigurable {
            return withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> FailableProgressable {
            return withConfig(config)
        }
    }
}
