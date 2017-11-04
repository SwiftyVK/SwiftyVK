extension SendableMethod {
    /// Send request synchronously.
    /// DO NOT USE IT IN MAIN THREAD!
    /// - parameter session: Session in which the request will be sent
    public func await(in session: Session) throws -> Data {
        guard !Thread.isMainThread else {
            throw VKError.cantAwaitOnMainThread
        }
        
        let request = toRequest()
        
        guard
            request.callbacks.onError == nil,
            request.callbacks.onSuccess == nil
            else {
                throw VKError.cantAwaitRequestWithSettedCallbacks
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, VKError>?
        
        request.callbacks.onSuccess = {
            result = .data($0)
            semaphore.signal()
        }
        request.callbacks.onError = {
            result = .error($0)
            semaphore.signal()
        }
        
        request.toMethod().send(in: session)
        semaphore.wait()
        
        guard let unwrappedResult = try result?.unwrap() else {
            throw VKError.unexpectedResponse
        }
        
        return unwrappedResult
    }
    
    /// Send request synchronously.
    /// DO NOT USE IT IN MAIN THREAD!
    public func await() throws -> Data {
        return try await(in: VK.sessions.default)
    }
}
