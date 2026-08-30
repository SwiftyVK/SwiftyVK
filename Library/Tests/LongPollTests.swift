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
            DispatchQueue.global().async {
                callbacks.onDisconnect()
            }
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
        let updates = json.compactMap { JSON(value: $0) } .dropFirst().toArray()
        
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
                    return XCTFail("Unexpected events: \(events)")
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

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_forwardEvents_whenLongPollReceivesEvents() async throws {
        // Given
        let longPoll = LongPollMock()
        let stream = longPoll.eventsStream()
        var iterator = stream.makeAsyncIterator()

        // When
        guard let receiveEvents = longPoll.onReceiveEvents else {
            return XCTFail("Expected Long Poll event receiver")
        }
        receiveEvents([.forcedStop])

        // Then
        guard
            let events = try await iterator.next(),
            case .forcedStop? = events.first
            else {
            return XCTFail("Expected long poll event")
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_stopLongPoll_whenConsumerIsCancelled() async {
        // Given
        let longPoll = LongPollMock()
        let streamStarted = expectation(description: "stream started")
        let longPollStopped = expectation(description: "long poll stopped")
        longPoll.onStart = {
            streamStarted.fulfill()
        }
        longPoll.onStop = {
            longPollStopped.fulfill()
        }

        let streamConsumer = Swift.Task {
            var iterator = longPoll.eventsStream().makeAsyncIterator()
            do {
                _ = try await iterator.next()
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [streamStarted], timeout: 1)
        streamConsumer.cancel()

        // Then
        await fulfillment(of: [longPollStopped], timeout: 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_useLatestVersion_byDefault() {
        // Given
        let longPoll = LongPollMock()

        // When
        _ = longPoll.eventsStream()

        // Then
        XCTAssertEqual(longPoll.lastVersion, .latest)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_remainActive_whenStopIsCalled() {
        // Given
        let longPoll = LongPollMock()
        let stream = longPoll.eventsStream()

        // When
        longPoll.stop()

        // Then
        XCTAssertTrue(longPoll.isActive)
        _ = stream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_throwAlreadyObserved_whenSecondConsumerStarts() async throws {
        // Given
        let longPoll = LongPollMock()
        let firstStream = longPoll.eventsStream()
        let second = longPoll.eventsStream()
        var secondIterator = second.makeAsyncIterator()

        // When
        let actualError: Error
        do {
            _ = try await secondIterator.next()
            return XCTFail("Expected an error")
        }
        catch {
            actualError = error
        }

        // Then
        XCTAssertEqual(actualError.toVK(), .longPollAlreadyObserved)
        var firstIterator = firstStream.makeAsyncIterator()
        guard let receiveEvents = longPoll.onReceiveEvents else {
            return XCTFail("Expected first Long Poll event receiver")
        }
        receiveEvents([.forcedStop])

        guard let events = try await firstIterator.next() else {
            return XCTFail("Expected first consumer events")
        }
        XCTAssertEqual(events.count, 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_throwAlreadyObserved_whenLegacyConsumerIsActive() async {
        // Given
        let longPoll = LongPollMock()
        longPoll.start { _ in }
        var iterator = longPoll.eventsStream().makeAsyncIterator()

        // When
        do {
            _ = try await iterator.next()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .longPollAlreadyObserved)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_forwardEvents_whenImplementationReceivesUpdates() async throws {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in callbacks.onConnect() }
        context.operationMaker.onMake = { _, taskData in
            let task = LongPollTaskMock()
            task.onMain = { taskData.onResponse([]) }
            return task
        }
        context.session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        var iterator = context.longPoll.eventsStream().makeAsyncIterator()

        // When
        let actualEvents = try await iterator.next()

        // Then
        guard let actualEvents else {
            return XCTFail("Expected events")
        }
        XCTAssertTrue(actualEvents.isEmpty)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_requestPassedVersion_whenStarted() async {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        let expectedVersion = LongPollVersion.second
        let longPollServerRequested = expectation(description: "Long Poll server requested")
        var actualVersion: String?
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in callbacks.onConnect() }
        context.operationMaker.onMake = { _, _ in LongPollTaskMock() }
        context.session.onSend = { method in
            actualVersion = method.toRequest().type.parameters?[Parameter.lpVersion.rawValue]
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
            longPollServerRequested.fulfill()
        }

        // When
        let stream = context.longPoll.eventsStream(version: expectedVersion)

        // Then
        await fulfillment(of: [longPollServerRequested], timeout: 1)
        XCTAssertEqual(actualVersion, expectedVersion.rawValue)
        _ = stream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_requestLatestVersion_byDefault() async {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        let expectedVersion = LongPollVersion.latest
        let longPollServerRequested = expectation(description: "Long Poll server requested")
        var actualVersion: String?
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in callbacks.onConnect() }
        context.operationMaker.onMake = { _, _ in LongPollTaskMock() }
        context.session.onSend = { method in
            actualVersion = method.toRequest().type.parameters?[Parameter.lpVersion.rawValue]
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
            longPollServerRequested.fulfill()
        }

        // When
        let stream = context.longPoll.eventsStream()

        // Then
        await fulfillment(of: [longPollServerRequested], timeout: 1)
        XCTAssertEqual(actualVersion, expectedVersion.rawValue)
        _ = stream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_remainActive_whenStopIsCalledOnImplementation() {
        // Given
        let context = makeContext()
        let stream = context.longPoll.eventsStream()

        // When
        context.longPoll.stop()

        // Then
        XCTAssertTrue(context.longPoll.isActive)
        _ = stream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_stopImplementation_whenConsumerIsCancelled() async {
        // Given
        let context = makeContext()
        let stream = context.longPoll.eventsStream()
        let consumerStarted = expectation(description: "stream consumer started")
        let consumer = Swift.Task {
            var iterator = stream.makeAsyncIterator()
            consumerStarted.fulfill()
            do {
                _ = try await iterator.next()
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [consumerStarted], timeout: 1)
        consumer.cancel()
        _ = await consumer.value

        // Then
        XCTAssertFalse(context.longPoll.isActive)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_startAgain_whenPreviousConsumerIsCancelled() async {
        // Given
        let context = makeContext()
        let stream = context.longPoll.eventsStream()
        let consumerStarted = expectation(description: "stream consumer started")
        let consumer = Swift.Task {
            var iterator = stream.makeAsyncIterator()
            consumerStarted.fulfill()
            do {
                _ = try await iterator.next()
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [consumerStarted], timeout: 1)
        consumer.cancel()
        _ = await consumer.value
        let secondStream = context.longPoll.eventsStream()

        // Then
        XCTAssertTrue(context.longPoll.isActive)
        _ = secondStream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_throwAlreadyObserved_whenSecondImplementationConsumerStarts() async {
        // Given
        let context = makeContext()
        let firstStream = context.longPoll.eventsStream()
        var second = context.longPoll.eventsStream().makeAsyncIterator()

        // When
        do {
            _ = try await second.next()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .longPollAlreadyObserved)
        }
        _ = firstStream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_remainActive_whenSecondImplementationConsumerIsRejected() {
        // Given
        let context = makeContext()
        let firstStream = context.longPoll.eventsStream()

        // When
        let secondStream = context.longPoll.eventsStream()

        // Then
        XCTAssertTrue(context.longPoll.isActive)
        _ = firstStream
        _ = secondStream
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_throwAlreadyObserved_whenLegacyImplementationConsumerIsActive() async {
        // Given
        let context = makeContext()
        context.longPoll.start { _ in }
        var iterator = context.longPoll.eventsStream().makeAsyncIterator()

        // When
        do {
            _ = try await iterator.next()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .longPollAlreadyObserved)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_start_doNothing_whenStreamIsActive() async throws {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        var connectionUpdate: ConnectionUpdate?
        let legacyCallbackCalled = expectation(description: "legacy callback called")
        legacyCallbackCalled.isInverted = true
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in
            connectionUpdate = callbacks
        }
        context.operationMaker.onMake = { _, taskData in
            let task = LongPollTaskMock()
            task.onMain = { taskData.onError(.unknown) }
            return task
        }
        context.session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        let stream = context.longPoll.eventsStream(version: .second)
        guard let connectionUpdate else {
            return XCTFail("Expected connection observer")
        }

        // When
        context.longPoll.start(version: .zero) { _ in legacyCallbackCalled.fulfill() }
        connectionUpdate.onConnect()
        var iterator = stream.makeAsyncIterator()

        // Then
        guard case .forcedStop? = try await iterator.next()?.first else {
            return XCTFail("Expected stream event")
        }
        await fulfillment(of: [legacyCallbackCalled], timeout: 0.1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_forwardForcedStop_whenTaskFails() async throws {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in callbacks.onConnect() }
        context.operationMaker.onMake = { _, taskData in
            let task = LongPollTaskMock()
            task.onMain = { taskData.onError(.unknown) }
            return task
        }
        context.session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        var iterator = context.longPoll.eventsStream().makeAsyncIterator()

        // When
        let event = try await iterator.next()?.first

        // Then
        guard case .forcedStop? = event else {
            return XCTFail("Expected forced stop")
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_eventsStream_forwardHistoryMayBeLost_whenTaskLosesHistory() async throws {
        // Given
        guard let serverData = JsonReader.read("longPoll.getServer.success"),
              let serverResponse = Response(serverData).data else {
            return XCTFail("Long Poll response is unavailable")
        }
        let context = makeContext()
        context.session.state = .authorized
        context.connectionObserver.onSubscribe = { _, callbacks in callbacks.onConnect() }
        context.operationMaker.onMake = { _, taskData in
            let task = LongPollTaskMock()
            task.onMain = { taskData.onError(.historyMayBeLost) }
            return task
        }
        context.session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected Long Poll server callback")
            }
            do {
                try onSuccess(serverResponse)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        var iterator = context.longPoll.eventsStream().makeAsyncIterator()

        // When
        let event = try await iterator.next()?.first

        // Then
        guard case .historyMayBeLost? = event else {
            return XCTFail("Expected history lost event")
        }
    }
    #endif
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
