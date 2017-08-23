import Foundation
import XCTest
@testable import SwiftyVK

class VkErrorTests: XCTestCase {
    
    func test_errorConvertationFromApiError() {
        // When
        let apiError = ApiError(code: 0)
        // Then
        XCTAssertEqual(VkError.api(apiError).toApi(), apiError)
    }
    
    func test_errorConvertationFromOtherError() {
        XCTAssertNil(VkError.unexpectedResponse.toApi())
    }
}
