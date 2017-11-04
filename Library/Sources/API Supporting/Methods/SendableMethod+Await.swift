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
        var data: Data?
        var error: VKError?
        
        request.callbacks.onSuccess = {
            data = $0
            semaphore.signal()
        }
        request.callbacks.onError = {
            error = $0
            semaphore.signal()
        }
        
        request.toMethod().send(in: session)
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        if let data = data {
            return data
        }
        
        throw VKError.unexpectedResponse
    }
    
    /// Send request synchronously.
    /// DO NOT USE IT IN MAIN THREAD!
    public func await() throws -> Data {
        return try await(in: VK.sessions.default)
    }
}
