import Foundation
import XCTest
@testable import SwiftyVK

final class LongPollTests: XCTestCase {

    func test_callOnConnected_onConnected() {
        // Given
        let expectation = self.expectation(description: "")
        let context = makeContext(
            onConnected: { expectation.fulfill() },
            onDisconnected: { XCTFail("Unexpected result") }
        )

        context.session.state = .authorized

        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }

        // When
        context.longPoll.start { _ in }
        // Then
        waitForExpectations(timeout: 5)
    }

    func test_callOnDisconnected_onDisconnected() {
        // Given
        let expectation = self.expectation(description: "")
        let context = makeContext(
            onDisconnected: { expectation.fulfill() }
        )
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
            callbacks.onDisconnect()
        }

        // When
        context.longPoll.start { _ in }
        // Then
        waitForExpectations(timeout: 5)
    }
//
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
            let operation = LongPollTaskMock()
            
            operation.onMain = {
                data.onResponse(updates)
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if case .type114? = events.last {
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
            let operation = LongPollTaskMock()
            
            operation.onMain = {
                data.onResponse([])
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if events.first?.data != nil {
                XCTFail("Unexpected events: \(events)")
            }
        }
        
        context.longPoll.stop()
        // Then
        waitForExpectations(timeout: 5)
    }

    func test_restartingUpdate_whenConnectionInfoLost() {
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
            let operation = LongPollTaskMock()
            
            operation.onMain = {
                if getInfoCallCount == 1 {
                    data.onError(.connectionInfoLost)
                } else {
                    data.onResponse([])
                }
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            getInfoCallCount += 1
            try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if events.isEmpty {
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
    
    func test_restartingUpdate_whenHistoryMayBeLost() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        
        let expectation = self.expectation(description: "")
        let context = makeContext()
        var taskCount = 0
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollTaskMock()
            
            operation.onMain = {
                taskCount += 1

                if taskCount == 1 {
                    data.onError(.historyMayBeLost)
                    operation.onMain?()
                } else {
                    data.onResponse([])
                }
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if taskCount == 1 {
                guard case .historyMayBeLost? = events.first else {
                    return XCTFail("Unexpected event: \(String(describing: events.first))")
                }
            } else if events.isEmpty {
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(taskCount, 2)
    }
    
    func test_restartingUpdate_whenUnexpectedError() {
        // Given
        guard let longPollServerData = JsonReader.read("longPoll.getServer.success") else { return }
        guard let longPollServerResponseData = Response(longPollServerData).data else {
            return XCTFail("response not parsed")
        }
        
        let expectation = self.expectation(description: "")
        let context = makeContext()
        var taskCount = 0
        
        context.session.state = .authorized
        
        context.connectionObserver.onSubscribe = { _, callbacks in
            callbacks.onConnect()
        }
        
        context.operationMaker.onMake = { _, data in
            let operation = LongPollTaskMock()
            
            operation.onMain = {
                taskCount += 1
                
                if taskCount == 1 {
                    data.onError(.unknown)
                } else {
                    data.onResponse([])
                }
            }
            
            return operation
        }
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
        }
        
        // When
        context.longPoll.start { events in
            if taskCount == 1 {
                guard case .forcedStop? = events.first else {
                    return XCTFail("Unexpected event: \(events.first)")
                }
                
                expectation.fulfill()
            }
            else {
                XCTFail("Unexpected events: \(events)")
            }
        }
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(taskCount, 1)
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
            let operation = LongPollTaskMock()
            
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
                try? method.toRequest().callbacks.onSuccess?(longPollServerResponseData)
            }
        }
        
        // When
        context.longPoll.start { events in
            if events.isEmpty {
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

private func makeContext(
    onConnected: (() -> ())? = nil,
    onDisconnected: (() -> ())? = nil
    ) -> (
    session: SessionMock,
    longPoll: LongPollImpl,
    operationMaker: LongPollTaskMakerMock,
    connectionObserver: ConnectionObserverMock
    ) {
    let session = SessionMock()
    let operationMaker = LongPollTaskMakerMock()
    let connectionObserver = ConnectionObserverMock()
    
    let longPoll = LongPollImpl(
        session: session,
        operationMaker: operationMaker,
        connectionObserver: connectionObserver,
        getInfoDelay: 0.1,
        onConnected: onConnected,
        onDisconnected: onDisconnected
    )
    
    return (session, longPoll, operationMaker, connectionObserver)
}

