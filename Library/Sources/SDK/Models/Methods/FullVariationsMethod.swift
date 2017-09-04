extension Methods {
    public final class SuccessableFailableProgressableConfigurable: Basic, Method {        
        public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> FailableProgressableConfigurable {
            return withOnSuccess(clousure)
        }
        
        public func onError(_ clousure: @escaping RequestCallbacks.Error) -> SuccessableProgressableConfigurable {
            return withOnError(clousure)
        }
        
        public func onProgress(_ clousure: @escaping RequestCallbacks.Progress) -> SuccessableFailableConfigurable {
            return withOnProgress(clousure)
        }
        
        public func configure(with config: Config) -> SuccessableFailableProgressable {
            return withConfig(config)
        }
    }
}
