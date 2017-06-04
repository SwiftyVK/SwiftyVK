import XCTest
@testable import SwiftyVK

final class SessionStorageTests: BaseTestCase {
    
    var storage: SessionStorageImpl {
        return SessionStorageImpl(sessionMaker: SessionMakerMock())
    }
    
    func test_makeNewSession() {
        XCTAssertTrue(storage.make() is SessionMock)
    }
    
    func test_markAsDefault() {
        // Given
        let storage = self.storage
        let oldSession = storage.default
        let newSession = storage.make()
        // When
        try? storage.markAsDefault(session: newSession)
        // Then
        XCTAssertFalse(storage.default === oldSession)
        XCTAssertTrue(storage.default === newSession)
    }
    
    func test_destroySession() {
        // Given
        let newSession = storage.make()
        // When
        try? storage.destroy(session: newSession)
        // Then
        XCTAssertEqual(newSession.state, .destroyed)
    }
    
    func test_autoDestroyAllSessions() {
        // Given
        let defaultSession = storage.default
        let newSession = storage.make()
        // Then
        XCTAssertEqual(defaultSession.state, .destroyed)
        XCTAssertEqual(newSession.state, .destroyed)
    }
    
    func test_destroyDefaultSession_shouldBeFail() {
        // Given
        let storage = self.storage
        // When
        do {
            try storage.destroy(session: storage.default)
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .cantDestroyDefaultSession)
            
        }
    }
    
    func test_destroyDeadSession_shouldBeFail() {
        // Given
        let storage = self.storage
        let session = storage.make()
        // When
        do {
            try storage.destroy(session: session)
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .sessionDestroyed)
            
        }
    }
    
    func test_getAllSessions() {
        // Given
        let storage = self.storage
        // When
        let sessions = [storage.make(), storage.make(), storage.make(), storage.make()]
        // Then
        XCTAssertEqual(storage.all.count, sessions.count)
    }
    
    
}
