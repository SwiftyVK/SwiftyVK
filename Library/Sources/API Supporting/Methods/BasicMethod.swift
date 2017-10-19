extension Methods {
    public class Basic: SendableMethod {
        let request: Request
        
        required public init(_ request: Request) {
            self.request = request
        }
        
        /// For internal using only!
        public func toRequest() -> Request {
            return request
        }
        
        /// Build chain of requests
        /// - parameter next: Clousure which recieve result of executing previos request
        /// and return next request
        public func chain(_ next: @escaping (Data) throws -> ChainableMethod) -> Self {
            request.add(next: next)
            return .init(request)
        }
        
        func withOnSuccess<T: Basic>(_ clousure: @escaping RequestCallbacks.Success) -> T {
            request.callbacks.onSuccess = clousure
            return .init(request)
        }
        
        func withOnError<T: Basic>(_ clousure: @escaping RequestCallbacks.Error) -> T {
            request.callbacks.onError = clousure
            return .init(request)
        }
        
        func withOnProgress<T: Basic>(_ clousure: @escaping RequestCallbacks.Progress) -> T {
            request.callbacks.onProgress = clousure
            return .init(request)
        }
        
        func withConfig<T: Basic>(_ config: Config) -> T {
            request.config = config
            return .init(request)
        }
    }
}
