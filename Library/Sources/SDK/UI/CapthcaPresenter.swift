protocol CaptchaPresenter {
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String
    func dismiss()
}

final class CaptchaPresenterImpl: CaptchaPresenter {
    
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: CaptchaControllerMaker
    private weak var currentController: CaptchaController?
    
    init(
        uiSyncQueue: DispatchQueue,
        controllerMaker: CaptchaControllerMaker
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controllerMaker = controllerMaker
    }
    
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        return try uiSyncQueue.sync {
            var result: String?
            
            guard
                let controller = currentController ?? controllerMaker.captchaController() else {
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
        currentController?.dismiss()
    }
    
    private func downloadCaptchaImageData(rawUrl: String) throws -> Data {
        guard let request = URL(string: rawUrl).flatMap({ URLRequest(url: $0) }) else {
            throw SessionError.cantLoadCaptchaImage
        }
        
        return try NSURLConnection.sendSynchronousRequest(request, returning: nil)
    }
}
