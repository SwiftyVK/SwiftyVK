protocol CaptchaPresenter {
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String
    func dismiss()
}

final class CaptchaPresenterImpl: CaptchaPresenter {
    
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: CaptchaControllerMaker
    private weak var currentController: CaptchaController?
    private let timeout: TimeInterval
    
    init(
        uiSyncQueue: DispatchQueue,
        controllerMaker: CaptchaControllerMaker,
        timeout: TimeInterval
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controllerMaker = controllerMaker
        self.timeout = timeout
    }
    
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        return try uiSyncQueue.sync {
            var result: String?
            
            guard let controller = currentController ?? controllerMaker.captchaController() else {
                throw LegacySessionError.cantMakeCaptchaController
            }
            
            currentController = controller
            
            controller.prepareForPresent()
            
            let imageData = try downloadCaptchaImageData(rawUrl: rawCaptchaUrl)
            
            controller.present(
                imageData: imageData,
                onResult: { [weak currentController] givenResult in
                    result = givenResult
                    
                    if dismissOnFinish {
                        currentController?.dismiss()
                    } else {
                        semaphore.signal()
                    }
                },
                onDismiss: {
                    semaphore.signal()
                }
            )
            
            switch semaphore.wait(timeout: .now() + timeout) {
            case .timedOut:
                throw LegacySessionError.captchaPresenterTimedOut
            case .success:
                break
            }
            
            guard let unwrappedResult = result else {
                throw LegacyRequestError.captchaFailed
            }
            
            return unwrappedResult
        }
    }
    
    func dismiss() {
        currentController?.dismiss()
    }
    
    private func downloadCaptchaImageData(rawUrl: String) throws -> Data {
        guard let request = URL(string: rawUrl).flatMap({ URLRequest(url: $0) }) else {
            throw LegacySessionError.cantLoadCaptchaImage
        }
        
        return try NSURLConnection.sendSynchronousRequest(request, returning: nil)
    }
}
