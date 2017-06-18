@testable import SwiftyVK

final class CaptchaControllerMock: CaptchaController {
    
    var onPrepareForPresent: (() -> ())?
    var onPresent: ((Data, (String) -> (), () -> ()) -> ())?
    var onDismiss: (() -> ())?
    
    func prepareForPresent() {
        onPrepareForPresent?()
    }
    
    func present(imageData: Data, onResult: @escaping (String) -> (), onDismiss: @escaping () -> ()) {
        onPresent?(imageData, onResult, onDismiss)
    }
    
    func dismiss() {
        onDismiss?()
    }
}
