import Foundation
import XCTest
@testable import SwiftyVK

final class SharePresenterTests: XCTestCase {
    
    func test() {
        // Given
        let presenter = SharePresenterImpl()
        let session = SessionMock()
        let shareContext = ShareContext()
        // When
        presenter.share(shareContext, in: session)
        // Then
    }
}
