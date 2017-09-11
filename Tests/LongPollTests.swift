import Foundation
import XCTest
@testable import SwiftyVK

class LongPollTests: XCTestCase {
    
    func test_sendConnectEvent_onConnected() {
        // Given
        let expectation = self.expectation(description: "")
        let context = makeContext()
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_sendDisconnectEvent_onDisconnected() {
        // Given
        let expectation = self.expectation(description: "")
        let context = makeContext()
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
            callbacks.onDisconnect()
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                // Do nothing
            }
            else if case .disconnect? = events.first {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_handleUpdates_whenStarted() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        guard
            let data = JsonReader.read("longPoll.updates"),
            let json: [Any] = data.toJson()?.array("updates") else {
                return XCTFail()
        }
        let updates = json.flatMap { JSON(value: $0) } .dropFirst().toArray()
        
        let expectation = self.expectation(description: "")
        let context = makeContext()

        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollUpdatingOperationMock()
            
            operation.onMain = {
                data.onResponse(updates)
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                // Do nothing
            }
            else if case .disconnect? = events.first {
                // Do nothing
            }
            else if case .type114? = events.last {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_notHandleUpdates_whenStopped() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        
        let expectation = self.expectation(description: "")
        expectation.isInverted = true
        
        let context = makeContext()
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollUpdatingOperationMock()
            
            operation.onMain = {
                data.onResponse([])
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                // Do nothing
            }
            else if case .disconnect? = events.first {
                // Do nothing
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        
        context.longPoll.stop()
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_restartingUpdate_whenKeyExpired() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        
        let expectation = self.expectation(description: "")
        let context = makeContext()
        var getInfoCallCount = 0
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollUpdatingOperationMock()
            
            operation.onMain = {
                if getInfoCallCount == 1 {
                    data.onKeyExpired()
                } else {
                    data.onResponse([])
                }
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            getInfoCallCount += 1
            method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                // Do nothing
            }
            else if case .disconnect? = events.first {
                // Do nothing
            }
            else if events.isEmpty {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(getInfoCallCount, 2)
    }
    
    func test_restartingUpdate_whenGetInfoFailing() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        
        let expectation = self.expectation(description: "")
        let context = makeContext()
        var getInfoCallCount = 0
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollUpdatingOperationMock()
            
            operation.onMain = {
                data.onResponse([])
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            getInfoCallCount += 1
            
            if getInfoCallCount == 1 {
                method.toRequest().callbacks.onError?(.unexpectedResponse)
            }
            else {
                method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
            }
        }
        
        // When
        context.longPoll.start { events in
            if case .connect? = events.first {
                // Do nothing
            }
            else if case .disconnect? = events.first {
                // Do nothing
            }
            else if events.isEmpty {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(getInfoCallCount, 2)
    }
}

private func makeContext() -> (
    session: SessionMock,
    longPoll: LongPollImpl,
    operationMaker: LongPollUpdatingOperationMakerMock,
    connectionObserver: ConnectionObserverMock
    ) {
    let session = SessionMock()
    let operationMaker = LongPollUpdatingOperationMakerMock()
    let connectionObserver = ConnectionObserverMock()
    
    let longPoll = LongPollImpl(
        session: session,
        operationMaker: operationMaker,
        connectionObserver: connectionObserver,
        getInfoDelay: 0.1
    )
    
    return (session, longPoll, operationMaker, connectionObserver)
}
