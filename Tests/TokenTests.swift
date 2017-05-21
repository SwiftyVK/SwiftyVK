import XCTest
@testable import SwiftyVK

final class TokenTests: BaseTestCase {
    
    func test_validToken_isValid() {
        // When
        let token = TokenImpl(token: "test", expires: 1, info: [:])
        // Then
        XCTAssertTrue(token.isValid)
        XCTAssertEqual(token.get(), "test")
    }
    
    func test_infinityToken_isValid() {
        // When
        let token = TokenImpl(token: "test", expires: 0, info: [:])
        // Then
        XCTAssertTrue(token.isValid)
        XCTAssertEqual(token.get(), "test")
    }
    
    func test_expiredToken_isNotValid() {
        // When
        let token = TokenImpl(token: "test", expires: 0.1, info: [:])
        
        Thread.sleep(forTimeInterval: 0.2)
        // Then
        XCTAssertFalse(token.isValid)
        XCTAssertNil(token.get())
    }
    
    
    func test_getInfo() {
        // When
        let token = TokenImpl(token: "test", expires: 0, info: ["test" : "test"])
        // Then
        XCTAssertEqual(token.info["test"], "test")
    }
    
    func test_infinityToken_nsCoding() {
        // Given
        let token = TokenImpl(token: "test", expires: 0, info: ["test" : "test"])
        // When
        let archived = NSKeyedArchiver.archivedData(withRootObject: token)
        let unarcheved = NSKeyedUnarchiver.unarchiveObject(with: archived) as? TokenImpl
        // Then
        XCTAssertNotNil(unarcheved)
        XCTAssertEqual(token.isValid, unarcheved?.isValid)
        XCTAssertEqual(token.get(), unarcheved?.get())
        XCTAssertEqual(token.info["test"], unarcheved?.info["test"])
    }
    
    func test_expiresToken_nsCoding() {
        // Given
        let token = TokenImpl(token: "test", expires: 0.1, info: ["test" : "test"])
        // When
        let archived = NSKeyedArchiver.archivedData(withRootObject: token)
        let unarcheved = NSKeyedUnarchiver.unarchiveObject(with: archived) as? TokenImpl
        Thread.sleep(forTimeInterval: 0.2)
        // Then
        XCTAssertNotNil(unarcheved)
        XCTAssertEqual(token.isValid, unarcheved?.isValid)
        XCTAssertEqual(token.get(), unarcheved?.get())
        XCTAssertEqual(token.info["test"], unarcheved?.info["test"])
        
        XCTAssertFalse(unarcheved?.isValid ?? true)
        XCTAssertNil(unarcheved?.get())
    }
}
