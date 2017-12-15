@testable import SwiftyVK
import XCTest

final class SharePresenterMock: SharePresenter {
    var onShare: ((ShareContext) throws -> Data)?
    
    func share(_ context: ShareContext, in session: Session) throws -> Data {
        return try onShare?(context) ?? Data()
    }
}
