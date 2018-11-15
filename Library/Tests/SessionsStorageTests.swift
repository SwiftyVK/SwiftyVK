import Foundation
import XCTest
@testable import SwiftyVK

final class SessionStorageTests: XCTestCase {
    
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
                        
            if fileManager.fileExists(atPath: fileUrl.path) {
                try fileManager.removeItem(at: fileUrl)
            }
        }
        catch let error {
            XCTFail("Config not removed with error: \(error)")
        }
    }
    
    func test_configPath_withRalativePath_haveBuildedCorreclty() {
        let storage = SessionsStorageImpl(
            fileManager: FileManager(),
            bundleName: "SwiftyVKTests",
            configName: "SwiftyVKConfig")
        
        do {
            let configUrl = try storage.configurationUrl()
            XCTAssertEqual(configUrl.lastPathComponent, "SwiftyVKConfig.plist")
            XCTAssertEqual(configUrl.pathComponents.dropLast().last, "SwiftyVKTests")
            XCTAssertEqual(configUrl.pathComponents.dropLast().dropLast().last, "Application Support")
        }
        catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_configPath_withAbsolutePath_haveBuildedCorreclty() {
        do {
            let configPath = try FileManager.default.url(
                for: FileManager.SearchPathDirectory.applicationDirectory,
                in: FileManager.SearchPathDomainMask.allDomainsMask,
                appropriateFor: nil,
                create: false)
                .appendingPathComponent("state.xml")
            
            let storage = SessionsStorageImpl(fileManager: FileManager(), bundleName: "", configName: configPath.path)
            
            XCTAssertEqual(try storage.configurationUrl().path, configPath.path)
        }
        catch let error {
            XCTFail("Unexpected error: \(error)")
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
        }
        catch let error {
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
        }
        catch let error {
            XCTAssertEqual((error as NSError).domain, NSCocoaErrorDomain)
            XCTAssertEqual((error as NSError).code, 260)
        }
    }
}

