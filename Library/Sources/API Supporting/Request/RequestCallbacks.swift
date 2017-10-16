public struct RequestCallbacks {
    public typealias Success = (Data) throws -> ()
    public typealias Error = (VKError) -> ()
    public typealias Progress = (ProgressType) -> ()

    public static let empty = RequestCallbacks()
    
    var onSuccess: Success?
    var onError: Error?
    var onProgress: Progress?
    
    public init(
        onSuccess: Success? = nil,
        onError: Error? = nil,
        onProgress: Progress? = nil
        ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onProgress = onProgress
    }
}

public enum ProgressType {
    case sent(current: Int64, of: Int64)
    case recieve(current: Int64, of: Int64)
}
