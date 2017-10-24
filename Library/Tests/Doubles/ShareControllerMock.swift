@testable import SwiftyVK
import XCTest

final class ShareControllerMock: ShareController {

    var onShare: ((ShareContext) -> ())?
    
    func share(_ context: ShareContext) {
        onShare?(context)
    }
}
