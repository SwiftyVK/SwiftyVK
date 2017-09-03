extension Methods {
    public final class Successable: Basic {
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Basic {
            return withOnSuccess(clousure)
        }
    }
    
    public final class Failable: Basic {
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Basic {
            return withOnError(clousure)
        }
    }
    
    public final class Progressable: Basic {
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> Basic {
            return withOnProgress(clousure)
        }
    }
    
    public final class Configurable: Basic {
        public func configure(with config: Config) -> Basic {
            return withConfig(config)
        }
    }
}
