@testable import SwiftyVK
import XCTest

final class ShareControllerMock: ShareController {
    
    var onDismiss: (() -> ())?
    
    var onShare: ((ShareContext, @escaping (ShareContext) -> ()) -> ())?
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
      onShare?(context, onPost)
    }
    
    var onShowPlaceholder: (() -> ())?
    
    func showPlaceholder() {
        onShowPlaceholder?()
    }
    
    var onShowWaitForConnection: (() -> ())?
    
    func showWaitForConnection() {
        onShowWaitForConnection?()
    }
    
    var onEnablePostButton: ((Bool) -> ())?
    
    func enablePostButton(_ enable: Bool) {
        onEnablePostButton?(enable)
    }
    
    var onClose: (() -> ())?
    
    func close() {
        onDismiss?()
        onClose?()
    }
    
    var onShowError: ((String, String, String) -> ())?
    
    func showError(title: String, message: String, buttontext: String) {
        onShowError?(title, message, buttontext)
    }
}
