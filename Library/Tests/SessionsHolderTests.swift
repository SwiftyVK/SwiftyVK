import XCTest
@testable import SwiftyVK

final class SessionsHolderTests: XCTestCase {
    
    func test_makeSession_isMock() {
        // Given
        let context = makeContext()
        // When
        let createdSession = context.holder.make(config: .default)
        // Then
        XCTAssertTrue(createdSession is SessionMock)
    }
    
    func test_makeSession_isSaved() {
        // Given
        let context = makeContext()
        var savedSession: EncodedSession?
        
        context.storage.onSave = { sessions in
            savedSession = sessions.first
        }
        // When
        let createdSession = context.holder.make(config: .default)
        // Then
        XCTAssertEqual(savedSession?.id, createdSession.id)
        XCTAssertEqual(savedSession?.config, createdSession.config)
        XCTAssertFalse(savedSession?.isDefault ?? true)
    }
    
    func test_markAsDefault_isMarked() {
        // Given
        let context = makeContext()
        let oldSession = context.holder.default
        let newSession = context.holder.make()
        
        // When
        try? context.holder.markAsDefault(session: newSession)
        // Then
        XCTAssertFalse(context.holder.default === oldSession)
        XCTAssertTrue(context.holder.default === newSession)
    }
    
    func test_markAsDefault_isSaved() {
        // Given
        let context = makeContext()
        let oldSession = context.holder.default
        let newSession = context.holder.make()
        
        context.storage.onSave = { sessions in
            // When
            XCTAssertEqual(sessions.count, 2)
            XCTAssertEqual(sessions.first { $0.isDefault }?.id, newSession.id)
            XCTAssertEqual(sessions.first { !$0.isDefault }?.id, oldSession.id)
        }
        
        // When
        try? context.holder.markAsDefault(session: newSession)
    }
    
    func test_destroySession() {
        // Given
        let context = makeContext()
        let newSession = context.holder.make()
        // When
        try? context.holder.destroy(session: newSession)
        // Then
        XCTAssertEqual(newSession.state, .destroyed)
    }
    
    func test_destroyDeadSession_shouldBeFail() {
        // Given
        let context = makeContext()
        let session = context.holder.make()
        // When
        do {
            try context.holder.destroy(session: session)
            try context.holder.destroy(session: session)
            XCTFail("Unexpected behavior")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.sessionAlreadyDestroyed(session))
        }
    }
    
    func test_getAllSessions() {
        // Given
        let context = makeContext()
        // When
        let sessions = [
            context.holder.make(),
            context.holder.make(),
            context.holder.make(),
            context.holder.make(),
            context.holder.default
        ]
        // Then
        XCTAssertEqual(context.holder.all.count, sessions.count)
    }
    
    func test_changeDefault() {
        // Given
        let context = makeContext()
        let oldDefaultId = context.holder.default.id
        context.holder.default.config = SessionConfig(apiVersion: "TEST")
        // When
        try? context.holder.destroy(session: context.holder.default)
        let newDefaultId = context.holder.default.id
        let newConfig = context.holder.default.config
        // Then
        XCTAssertNotEqual(oldDefaultId, newDefaultId)
        XCTAssertEqual(newConfig.apiVersion, "TEST")
    }
}

private func makeContext() -> (holder: SessionsHolderImpl, maker: SessionMakerMock, storage: SessionsStorageMock) {
    let sessionMaker = SessionMakerMock()
    let sessionsStorage = SessionsStorageMock()
    
    let sessionsHolder = SessionsHolderImpl(
        sessionMaker: sessionMaker,
        sessionsStorage: sessionsStorage
    )
    
    return (sessionsHolder, sessionMaker, sessionsStorage)
}
