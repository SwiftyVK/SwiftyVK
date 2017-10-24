import Foundation
import XCTest
@testable import SwiftyVK

final class SharePresenterTests: XCTestCase {
    
    func test_share_shareControllerMaked() {
        // Given
        let controllerMaker = ShareControllerMakerMock()
        let presenter = SharePresenterImpl(controllerMaker: controllerMaker)
        let session = SessionMock()
        let shareContext = ShareContext()
        var controllerMakerCallCount = 0
        
        controllerMaker.onMake = {
            controllerMakerCallCount += 1
            return ShareControllerMock()
        }
        // When
        presenter.share(shareContext, in: session)
        // Then
        XCTAssertEqual(controllerMakerCallCount, 1)
    }
}
