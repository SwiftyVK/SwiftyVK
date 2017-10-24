@testable import SwiftyVK
import XCTest

final class SharePresenterMock: SharePresenter {
    
    var onShare: ((ShareContext, Session) -> ())?
    
    func share(_ context: ShareContext, in session: Session) {
        onShare?(context, session)
    }
    
}

