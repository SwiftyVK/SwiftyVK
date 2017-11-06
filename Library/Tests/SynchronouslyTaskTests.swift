import Foundation
import XCTest
@testable import SwiftyVK

final class SynchronouslyTaskTests: XCTestCase {
    
    override func setUp() {
        VKStack.mock()
    }
    
    func test_send_throwError_whenSendOnMainThread() {
        // Given
        let task = VK.API.Users.get(.empty).synchronously()
        // When
        do {
            _ = try task.send()
            XCTFail("Unexpected response")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .cantAwaitOnMainThread)
        }
    }
    
    func test_send_throwError_whenSuccessCallbackIsSet() {
        // Given
        let task = VK.API.Users.get(.empty).onSuccess { _ in } .synchronously()
        let exp = expectation(description: "")
        // When
        DispatchQueue.global().async {
            do {
                _ = try task.send()
                XCTFail("Unexpected response")
                exp.fulfill()
            }
            catch {
                // Then
                XCTAssertEqual(error.toVK(), .cantAwaitRequestWithSettedCallbacks)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_send_throwError_whenErrorCallbackIsSet() {
        // Given
        let task = VK.API.Users.get(.empty).onError { _ in } .synchronously()
        let exp = expectation(description: "")
        // When
        DispatchQueue.global().async {
            do {
                _ = try task.send()
                XCTFail("Unexpected response")
                exp.fulfill()
            }
            catch {
                // Then
                XCTAssertEqual(error.toVK(), .cantAwaitRequestWithSettedCallbacks)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_send_returnEmptyData_whenSendindSucessed() {
        // Given
        let task = VK.API.Users.get(.empty).synchronously()
        let exp = expectation(description: "")
        
        (VK.sessions.default as? SessionMock)?.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(Data())
        }
        
        // When
        DispatchQueue.global().async {
            do {
                let data = try task.send()
                XCTAssertEqual(data?.count, 0)
                exp.fulfill()
            }
            catch {
                // Then
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_send_throwError_whenSendindFailed() {
        // Given
        let task = VK.API.Users.get(.empty).synchronously()
        let exp = expectation(description: "")
        
        (VK.sessions.default as? SessionMock)?.onSend = { method in
            method.toRequest().callbacks.onError?(.unexpectedResponse)
        }
        
        // When
        DispatchQueue.global().async {
            do {
                _ = try task.send()
                XCTFail("Unexpected response")
                exp.fulfill()
            }
            catch {
                // Then
                XCTAssertEqual(error.toVK(), .unexpectedResponse)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
