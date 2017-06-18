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
                throw SessionError.cantMakeCaptchaController
            }
            
            controller.prepareForPresent()
            
            let imageData = try downloadCaptchaImageData(rawUrl: rawCaptchaUrl)
            
            controller.present(
                imageData: imageData,
                onResult: { [weak self] givenResult in
                    result = givenResult
                    
                    if dismissOnFinish {
                        self?.dismiss()
                    } else {
                        semaphore.signal()
                    }
                },
                onDismiss: {
                    semaphore.signal()
                }
            )
            
            currentController = controller
            
            switch semaphore.wait(timeout: .now() + timeout) {
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
        currentController?.dismiss()
    }
    
    private func downloadCaptchaImageData(rawUrl: String) throws -> Data {
        guard let request = URL(string: rawUrl).flatMap({ URLRequest(url: $0) }) else {
            throw SessionError.cantLoadCaptchaImage
        }
        
        return try NSURLConnection.sendSynchronousRequest(request, returning: nil)
    }
}
