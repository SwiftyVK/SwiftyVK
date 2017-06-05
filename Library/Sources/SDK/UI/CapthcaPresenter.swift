protocol CaptchaPresenter {
    func present(captchaUrlString: String) throws -> String
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
    
    func present(captchaUrlString: String) throws -> String {
        let canFinish = Atomic(true)
        let semaphore = DispatchSemaphore(value: 0)
        
        return try uiSyncQueue.sync {
            
            let imageData = try downloadCaptchaImageData(string: captchaUrlString)
            
            var result: String?
            
            controller.present(imageData: imageData) { [controller] answer in
                canFinish >< { canFinish in
                    guard canFinish else {
                        return false
                    }
                    
                    result = answer
                    controller.dismiss()
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
    
    private func downloadCaptchaImageData(string: String) throws -> Data {
        guard let request = URL(string: string).flatMap({ URLRequest(url: $0) }) else {
            throw SessionError.cantLoadCaptchaImage
        }
        
        return try NSURLConnection.sendSynchronousRequest(request, returning: nil)
    }
}
