import XCTest
@testable import SwiftyVK

final class TokenStorageTests: BaseTestCase {
    
    func test_getSaved() {
        // Given
        let repository = TokenStorageImpl()
        let id = "testId"
        // When
        let token = TokenMock()
        repository.save(token: token, for: id)
        let restoredToken = repository.getFor(sessionId: id) as? TokenMock
        // Then
        XCTAssertEqual(restoredToken?.token, token.token)
    }
    
    func test_getRemoved() {
        // Given
        let repository = TokenStorageImpl()
        let id = "testId"
        // When
        repository.removeFor(sessionId: id)
        let restoredToken = repository.getFor(sessionId: id) as? TokenMock
        // Then
        XCTAssertNil(restoredToken?.token)
    }
}
