@testable import SwiftyVK
import XCTest

final class SharePresenterMock: SharePresenter {

    var onShare: ((ShareContext, Session, @escaping () -> (), @escaping RequestCallbacks.Error) -> ())?
    
    func share(_ context: ShareContext, in session: Session, onSuccess: @escaping () -> (), onError: @escaping RequestCallbacks.Error) {
        onShare?(context, session, onSuccess, onError)
    }
}
