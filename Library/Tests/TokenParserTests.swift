import XCTest
@testable import SwiftyVK

final class TokenParserTests: XCTestCase {
    
    func test_parseValidToken() {
        // Given
        let parser = TokenParserImpl()
        let info = "access_token=1234567890&expires_in=123&info=testInfo"
        // When
        let result = parser.parse(tokenInfo: info)
        // Then
        XCTAssertEqual(result?.token, "1234567890")
        XCTAssertEqual(result?.expires, 123)
        XCTAssertEqual(result?.info ?? [:], ["info": "testInfo", "access_token": "1234567890", "expires_in": "123"])
    }
    
    func test_parseTokenWithoutExpires() {
        // Given
        let parser = TokenParserImpl()
        let info = "access_token=1234567890&info=testInfo"
        // When
        let result = parser.parse(tokenInfo: info)
        // Then
        XCTAssertNil(result)
    }
    
    func test_parseWithoutToken() {
        // Given
        let parser = TokenParserImpl()
        let info = "expires_in=123&info=testInfo"
        // When
        let result = parser.parse(tokenInfo: info)
        // Then
        XCTAssertNil(result)
    }
}
