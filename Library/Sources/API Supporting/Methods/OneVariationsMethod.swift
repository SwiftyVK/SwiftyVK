extension Methods {
    public final class Successable: Basic {
        /// Set onSuccess callback
        /// - parameter clousure: callback which will be executed when request is successfully sended
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Basic {
            return withOnSuccess(clousure)
        }
    }
    
    public final class Failable: Basic {
        /// Set onError callback
        /// - parameter clousure: callback which will be executed when request is failed
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Basic {
            return withOnError(clousure)
        }
    }
    
    public final class Progressable: Basic {
        /// Set onProgress callback
        /// - parameter clousure: callback which will be executed when request upload part of file
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Basic {
            return withOnProgress(clousure)
        }
    }
    
    public final class Configurable: Basic {
        /// Set values which override session configuration for this request
        /// - parameter config: new request config
        public func configure(with config: Config) -> Basic {
            return withConfig(config)
        }
    }
}
