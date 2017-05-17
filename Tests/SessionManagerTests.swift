import XCTest
@testable import SwiftyVK

final class SessionManagerTests: BaseTestCase {
    
    var manager: SessionManagerImpl {
        return SessionManagerImpl(dependencyBox: dependencyBoxMock)
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
    
    func test_attemptToKillDefaultSession() {
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
}
