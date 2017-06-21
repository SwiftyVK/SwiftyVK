import Foundation
import XCTest
@testable import SwiftyVK

class SessionStorageTests: XCTestCase {
    
    func makeStorage() -> SessionsStorageImpl {
        return SessionsStorageImpl(fileManager: FileManager(), bundleName: "", configName: "")
    }
    
    override func setUp() {
        removeConfig()
    }
    
    override func tearDown() {
        removeConfig()
    }
    
    private func removeConfig() {
        do {
            let fileUrl = try makeStorage().configurationUrl()
            let fileManager = FileManager.default
            
            print(fileUrl.absoluteString)
            
            if fileManager.fileExists(atPath: fileUrl.path) {
                try fileManager.removeItem(at: fileUrl)
            }
        } catch let error {
            XCTFail("Config not removed with error: \(error)")
        }
    }
    
    func test_successfulRestored_whenRestoreAfterSave() {
        // Given
        let storage = makeStorage()
        let session = EncodedSession(isDefault: false, id: "test", config: .default)
        // When
        do {
            try storage.save(sessions: [session])
            let restoredSessions = try storage.restore()
            // Then
            XCTAssertEqual(session.id, restoredSessions.first?.id)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_throwError_whenRestoreWithoutSave() {
        // Given
        let storage = makeStorage()
        // When
        do {
            _ = try storage.restore()
            // Then
            XCTFail("Expression should throw error")
        } catch let error {
            XCTAssertEqual((error as NSError).domain, NSCocoaErrorDomain)
            XCTAssertEqual((error as NSError).code, 260)
        }
    }
}

