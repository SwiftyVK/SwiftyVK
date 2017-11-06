@testable import SwiftyVK
import XCTest

final class ShareControllerMock: ShareController {
    
    var onDismiss: (() -> ())?
    var onShare: ((ShareContext, (ShareContext) -> ()) -> ())?
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
      onShare?(context, onPost)
    }
    
    func showPlaceholder(_ enable: Bool) {
        
    }
    
    func showWaitForConnection() {
    }
    
    func enablePostButton(_ enable: Bool) {
        
    }
    
    var onClose: (() -> ())?
    
    func close() {
        onClose?()
    }
    
    var onShowError: ((String, String, String) -> ())?
    
    func showError(title: String, message: String, buttontext: String) {
        onShowError?(title, message, buttontext)
    }
}
