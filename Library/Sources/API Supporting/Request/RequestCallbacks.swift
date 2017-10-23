public struct RequestCallbacks {
    /// Clousure (Data) throws -> ()
    public typealias Success = (Data) throws -> ()
    /// Clousure (VKError) -> ()
    public typealias Error = (VKError) -> ()
    /// Clousure (ProgressType) -> ()
    public typealias Progress = (ProgressType) -> ()

    public static let empty = RequestCallbacks()
    
    var onSuccess: Success?
    var onError: Error?
    var onProgress: Progress?
    
    init(
        onSuccess: Success? = nil,
        onError: Error? = nil,
        onProgress: Progress? = nil
        ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onProgress = onProgress
    }
}

/// Represents progress of VK.API.Upload method group
/// - sent: progress of sending
/// - recieve: progress of receiving
public enum ProgressType {
    case sent(current: Int64, of: Int64)
    case recieve(current: Int64, of: Int64)
}
