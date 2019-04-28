extension Methods {
    public final class SuccessableFailableProgressableConfigurable: Basic, Method {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sent 
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressableConfigurable {
            return withOnSuccess(clousure)
        }
        
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressableConfigurable {
            return withOnError(clousure)
        }
        
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailableConfigurable {
            return withOnProgress(clousure)
        }
        
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> SuccessableFailableProgressable {
            return withConfig(config)
        }
    }
}
