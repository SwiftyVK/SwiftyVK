import Foundation
import XCTest
@testable import SwiftyVK

class VKErrorTests: XCTestCase {
    
    func test_errorConvertationFromApiError() {
        // When
        let apiError = ApiError(code: 0)
        // Then
        XCTAssertEqual(VKError.api(apiError).toApi(), apiError)
    }
    
    func test_errorConvertationFromOtherError() {
        XCTAssertNil(VKError.unexpectedResponse.toApi())
    }
}
