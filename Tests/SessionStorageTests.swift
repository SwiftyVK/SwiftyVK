import XCTest
@testable import SwiftyVK

final class SessionStorageTests: BaseTestCase {
    
    var manager: SessionStorageImpl {
        return SessionStorageImpl(dependencyBox: dependencyBoxMock)
    }
    
    func test_makeNewSession() {
        XCTAssertTrue(manager.new() is SessionMock)
    }
    
    func test_makeDefaultSession() {
        // Given
        let manager = self.manager
        let oldSession = manager.default
        let newSession = manager.new()
        // When
        manager.makeDefault(session: newSession)
        // Then
        XCTAssertFalse(manager.default === oldSession)
        XCTAssertTrue(manager.default === newSession)
    }
    
    func test_killSession() {
        // Given
        let newSession = manager.new()
        // When
        try? manager.kill(session: newSession)
        // Then
        XCTAssertEqual(newSession.state, .dead)
    }
    
    func test_autoKillAllSessions() {
        // Given
        let defaultSession = manager.default
        let newSession = manager.new()
        // Then
        XCTAssertEqual(defaultSession.state, .dead)
        XCTAssertEqual(newSession.state, .dead)
    }
    
    func test_killDefaultSession_shouldBeFail() {
        // Given
        let manager = self.manager
        // When
        do {
            try manager.kill(session: manager.default)
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .cantKillDefaultSession)
            
        }
    }
    
    func test_killDeadSession_shouldBeFail() {
        // Given
        let manager = self.manager
        let session = manager.new()
        // When
        do {
            try manager.kill(session: session)
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .sessionIsDead)
            
        }
    }
    
    func test_getAllSessions() {
        // Given
        let manager = self.manager
        // When
        let sessions = [manager.new(), manager.new(), manager.new(), manager.new()]
        // Then
        XCTAssertEqual(manager.all.count, sessions.count)
    }
    
    
}
