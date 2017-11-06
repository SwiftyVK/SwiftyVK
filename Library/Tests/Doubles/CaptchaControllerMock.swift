@testable import SwiftyVK

final class CaptchaControllerMock: CaptchaController {

    var onPrepareForPresent: (() -> ())?
    var onPresent: ((Data, (String) -> ()) -> ())?
    var onDismiss: (() -> ())?
    private var onRealDismiss: (() -> ())?
    
    func prepareForPresent() {
        onPrepareForPresent?()
    }
    
    func present(imageData: Data, onResult: @escaping (String) -> ()) {
        onPresent?(imageData, onResult)
    }
    
    func dismiss() {
        onDismiss?()
        onRealDismiss?()
    }
}
