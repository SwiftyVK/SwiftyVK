public struct Callbacks {
    public typealias Success = (Data) -> ()
    public typealias Error = (VKError) -> ()
    public typealias Progress = (_ type: ProgressType, _ current: Int64, _ of: Int64) -> ()

    public static let empty = Callbacks()
    
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
