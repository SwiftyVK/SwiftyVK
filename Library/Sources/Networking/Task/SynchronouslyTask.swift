import Foundation

public final class SynchronouslyTask: Task {
    private var request: Request
    private var task: Task?
    
    public var state: TaskState {
        return task?.state ?? .created
    }
    
    init(request: Request) {
        self.request = request
    }
    
    /// Send request synchronously.
    /// DO NOT USE IT IN MAIN THREAD!
    /// AND REQUEST SHOUL NOT CONTAINS CALLBACKS!
    /// - parameter session: Session in which the request will be sent
    public func send() throws -> Data? {
        return try send(in: VK.sessions.default)
    }
    
    /// Send request synchronously.
    /// DO NOT USE IT IN MAIN THREAD!
    /// AND REQUEST SHOULD NOT CONTAINS CALLBACKS!
    public func send(in session: Session) throws -> Data? {
        guard !Thread.isMainThread else {
            throw VKError.cantAwaitOnMainThread
        }
        
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
        
        task = request.toMethod().send(in: session)
        semaphore.wait()

        return try result?.unwrap()
    }
    
    public func cancel() {
        task?.cancel()
    }
}
