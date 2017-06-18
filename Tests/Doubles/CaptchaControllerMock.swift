@testable import SwiftyVK

final class CaptchaControllerMock: CaptchaController {
    
    var onPrepareForPresent: (() -> ())?
    var onPresent: ((Data, (String) -> (), () -> ()) -> ())?
    var onDismiss: (() -> ())?
    private var onRealDismiss: (() -> ())?
    
    func prepareForPresent() {
        onPrepareForPresent?()
    }
    
    func present(imageData: Data, onResult: @escaping (String) -> (), onDismiss: @escaping () -> ()) {
        onPresent?(imageData, onResult, onDismiss)
    }
    
    func dismiss() {
        onDismiss?()
        onRealDismiss?()
    }
}
