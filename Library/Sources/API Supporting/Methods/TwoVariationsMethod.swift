extension Methods {
    public final class SuccessableFailable: Basic, ChainableMethod {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Failable {
            return withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Successable {
            return withOnError(clousure)
        }
    }
    
    public final class SuccessableProgressable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Progressable {
            return withOnSuccess(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Successable {
            return withOnProgress(clousure)
        }
    }
    
    public final class SuccessableConfigurable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Configurable {
            return withOnSuccess(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Successable {
            return withConfig(config)
        }
    }
    
    public final class FailableConfigurable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Configurable {
            return withOnError(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Failable {
            return withConfig(config)
        }
    }
    
    public final class FailableProgressable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Progressable {
            return withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Failable {
            return withOnProgress(clousure)
        }
    }
    
    public final class ProgressableConfigurable: Basic {
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Configurable {
            return withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Progressable {
            return withConfig(config)
        }
    }
}
