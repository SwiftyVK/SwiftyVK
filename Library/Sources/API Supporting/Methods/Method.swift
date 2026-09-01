import Foundation

/// Protocol constraint which allows send request
public protocol SendableMethod {
    /// For internal using only
    func toRequest() -> Request
}

extension SendableMethod {
    
    /// Shedule request to sending
    @discardableResult
    public func send() -> Task {
        send(in: VK.sessions.default)
    }
    
    @discardableResult
    func send(in session: Session) -> Task {
        session.send(method: self)
    }
    
    /// Returns convert request to synchronously version.
    public func synchronously() -> SynchronouslyTask {
        SynchronouslyTask(request: toRequest())
    }

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    public func send() async throws -> Data {
        try await send(in: VK.sessions.default)
    }

    /// Sends request and waits for response.
    /// Throws `VKError.cantAwaitRequestWithSettedCallbacks` when request callbacks are already set.
    @available(iOS 13.0, macOS 10.15, *)
    public func send(in session: Session) async throws -> Data {
        let request = toRequest()

        guard
            request.callbacks.onSuccess == nil,
            request.callbacks.onError == nil
            else {
                throw VKError.cantAwaitRequestWithSettedCallbacks
        }

        let continuationBox = ContinuationBox<Data>()

        return try await withTaskCancellationHandler(
            operation: {
                try Swift.Task.checkCancellation()

                return try await withCheckedThrowingContinuation { continuation in
                    guard continuationBox.begin(with: continuation) else { return }

                    request.callbacks.onSuccess = { data in
                        continuationBox.succeed(with: data)
                    }
                    request.callbacks.onError = { error in
                        continuationBox.fail(with: error)
                    }

                    guard continuationBox.shouldStartOperation() else { return }

                    let task = session.send(method: request.toMethod())
                    continuationBox.registerCancellation {
                        task.cancel()
                    }
                }
            },
            onCancel: {
                continuationBox.cancel()
            }
        )
    }

    @available(iOS 13.0, macOS 10.15, *)
    public func sendWithProgress() -> AsyncThrowingStream<RequestStreamEvent, Error> {
        sendWithProgress(in: VK.sessions.default)
    }

    /// Sends request and returns its progress events stream.
    /// The stream finishes after response, error, or cancellation.
    @available(iOS 13.0, macOS 10.15, *)
    public func sendWithProgress(in session: Session) -> AsyncThrowingStream<RequestStreamEvent, Error> {
        let request = toRequest()

        return AsyncThrowingStream { continuation in
            guard
                request.callbacks.onSuccess == nil,
                request.callbacks.onError == nil,
                request.callbacks.onProgress == nil
                else {
                    return continuation.finish(throwing: VKError.cantAwaitRequestWithSettedCallbacks)
            }

            request.callbacks.onProgress = { progress in
                continuation.yield(.progress(progress))
            }
            request.callbacks.onSuccess = { data in
                continuation.yield(.response(data))
                continuation.finish()
            }
            request.callbacks.onError = { error in
                continuation.finish(throwing: error)
            }

            let task = session.send(method: request.toMethod())
            continuation.onTermination = { termination in
                guard case .cancelled = termination else { return }
                task.cancel()
            }
        }
    }
    #endif
}

/// Protocol constraint which allows build chains of requests
public protocol ChainableMethod: SendableMethod {}

public protocol Method: ChainableMethod {}

extension Method {
    /// Set onSuccess callback
    /// - parameter clousure: callback which will be executed when request is successfully sent
    public func onSuccess(_ clousure: @escaping RequestCallbacks.Success) -> Methods.FailableConfigurable {
        let request = toRequest()
        request.callbacks.onSuccess = clousure
        return .init(request)
    }
    
    /// Set onError callback
    /// - parameter clousure: callback which will be executed when request is failed
    public func onError(_ clousure: @escaping RequestCallbacks.Error) -> Methods.SuccessableConfigurable {
        let request = toRequest()
        request.callbacks.onError = clousure
        return .init(request)
    }
    
    /// Set values which override session configuration for this request
    /// - parameter config: new request config
    public func configure(with config: Config) -> Methods.SuccessableFailable {
        let request = toRequest()
        request.config = config
        return .init(request)
    }
    
    /// Build chain of requests
    /// - parameter next: Clousure which recieve result of executing previos request
    /// and return next request
    public func chain(_ next: @escaping (Data) throws -> ChainableMethod) -> Methods.SuccessableFailableConfigurable {
        let request = toRequest()
        request.add(next: next)
        return .init(request)
    }
}

public struct Methods {}
