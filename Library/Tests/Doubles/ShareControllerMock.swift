@testable import SwiftyVK
import XCTest

final class ShareControllerMock: ShareController {
    
    var onShare: ((ShareContext, @escaping (ShareContext) -> ()) -> ())?
    
    func share(_ context: ShareContext, completion: @escaping (ShareContext) -> ()) {
        onShare?(context, completion)
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
