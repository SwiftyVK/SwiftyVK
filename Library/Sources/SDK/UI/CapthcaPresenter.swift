import Foundation

protocol CaptchaPresenter {
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String
    func dismiss()
}

final class CaptchaPresenterImpl: CaptchaPresenter {
    
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: CaptchaControllerMaker
    private weak var currentController: CaptchaController?
    private let timeout: TimeInterval
    private let urlSession: VKURLSession
    
    init(
        uiSyncQueue: DispatchQueue,
        controllerMaker: CaptchaControllerMaker,
        timeout: TimeInterval,
        urlSession: VKURLSession
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.controllerMaker = controllerMaker
        self.timeout = timeout
        self.urlSession = urlSession
    }
    
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        
        return try uiSyncQueue.sync {
            var result: String?
            
            guard let controller = currentController ?? controllerMaker.captchaController() else {
                throw VKError.cantMakeCaptchaController
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
                    }
                    else {
                        semaphore.signal()
                    }
                },
                onDismiss: {
                    semaphore.signal()
                }
            )
            
            switch semaphore.wait(timeout: .now() + timeout) {
            case .timedOut:
                throw VKError.captchaPresenterTimedOut
            case .success:
                break
            }
            
            guard let unwrappedResult = result else {
                throw VKError.captchaResultIsNil
            }
            
            return unwrappedResult
        }
    }
    
    func dismiss() {
        currentController?.dismiss()
    }
    
    private func downloadCaptchaImageData(rawUrl: String) throws -> Data {
        guard let url = URL(string: rawUrl) else {
            throw VKError.cantMakeCapthaImageUrl(rawUrl)
        }
        
        let result = urlSession.synchronousDataTaskWithURL(url: url)
        
        if let error = result.error {
            throw VKError.cantLoadCaptchaImage(error)
        }
        else if let data = result.data {
            return data
        }
        
        throw VKError.cantLoadCaptchaImageWithUnknownReason
    }
}
