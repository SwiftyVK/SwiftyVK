protocol CaptchaPresenter {
    func present(rawCaptchaUrl: String) throws -> String
    func dismiss()
}

final class CaptchaPresenterImpl: CaptchaPresenter {
    
    private let uiSyncQueue: DispatchQueue
    private let controller: CaptchaController
    
    init(
        uiSyncQueue: DispatchQueue,
        controller: CaptchaController
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controller = controller
    }
    
    func present(rawCaptchaUrl: String) throws -> String {
        let canFinish = Atomic(true)
        let semaphore = DispatchSemaphore(value: 0)
        let imageData = try downloadCaptchaImageData(rawUrl: rawCaptchaUrl)
        
        return try uiSyncQueue.sync {
            var result: String?
            
            controller.present(imageData: imageData) { answer in
                canFinish >< { canFinish in
                    guard canFinish else {
                        return false
                    }
                    
                    result = answer
                    semaphore.signal()
                    return false
                }
            }
            
            switch semaphore.wait(timeout: .now() + 600) {
            case .timedOut:
                throw SessionError.captchaPresenterTimedOut
            case .success:
                break
            }
            
            guard let unwrappedResult = result else {
                throw RequestError.captchaFailed
            }
            
            return unwrappedResult
        }
    }
    
    func dismiss() {
        controller.dismiss()
    }
    
    private func downloadCaptchaImageData(rawUrl: String) throws -> Data {
        guard let request = URL(string: rawUrl).flatMap({ URLRequest(url: $0) }) else {
            throw SessionError.cantLoadCaptchaImage
        }
        
        return try NSURLConnection.sendSynchronousRequest(request, returning: nil)
    }
}
