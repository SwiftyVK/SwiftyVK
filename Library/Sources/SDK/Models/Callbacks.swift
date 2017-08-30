public struct Callbacks {
    public static let empty = Callbacks()
    
    var onSuccess: ((Data) -> ())?
    var onError: ((VKError) -> ())?
    var onProgress: ((_ type: ProgressType, _ current: Int64, _ of: Int64) -> ())?
    
    public init(
        onSuccess: ((Data) -> ())? = nil,
        onError: ((VKError) -> ())? = nil,
        onProgress: ((_ type: ProgressType, _ current: Int64, _ of: Int64) -> ())? = nil
        ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onProgress = onProgress
    }
}
