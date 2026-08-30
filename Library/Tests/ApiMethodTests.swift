import Foundation
import XCTest
@testable import SwiftyVK

final class ApiMethodTests: XCTestCase {
    
    func test_name_equalsToMethodName() {
        // When
        let method = APIScope.Users.get(.empty).toRequest().type.apiMethod
        // Then
        XCTAssertEqual(method, "users.get")
    }
    
    func test_apiMethodParameters_isEmpty() {
        // When
        let parameters = APIScope.Users.get(.empty).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_parameters_equalsToMethodParameters() {
        // When
        let parameter = [Parameter.userId: "1"]
        let parameters = APIScope.Users.get(parameter).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?[Parameter.userId.rawValue] ?? "", "1")
    }
    
    func test_callSessionSend_whenMethodSended() {
        // Given
        var sendCallCount = 0
        let method = APIScope.Users.get(.empty)
        VKStack.mock(method) { sendCallCount += 1 }
        // When
        method.send()
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
    
    func test_setConfig() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailable.self)
    }
    
    func test_setOnSuccess() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableConfigurable.self)
    }
    
    func test_setOnError() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableConfigurable.self)
    }
    
    func test_setNext() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
        
        do {
            let lastRequest = try mutatedMethod.toRequest().next(with: Data())?.next(with: Data())?.next(with: Data())
            // Then
            XCTAssertNotNil(lastRequest)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_returnResponse_whenSessionSucceeds() async throws {
        // Given
        let session = SessionMock()
        let expectedData = Data([1, 2, 3])
        session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected success callback")
            }
            do {
                try onSuccess(expectedData)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        let actualData = try await APIScope.Users.get(.empty).send(in: session)

        // Then
        XCTAssertEqual(actualData, expectedData)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSessionSend_returnResponse_whenLegacySessionSucceeds() async throws {
        // Given
        let session = SessionMock()
        let expectedData = Data([1, 2, 3])
        session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected success callback")
            }
            do {
                try onSuccess(expectedData)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        let actualData = try await session.send(method: APIScope.Users.get(.empty))

        // Then
        XCTAssertEqual(actualData, expectedData)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_throwCallbacksError_whenSuccessCallbackIsSet() async {
        // Given
        let method = APIScope.Users.get(.empty).onSuccess { _ in }

        // When
        do {
            _ = try await method.send(in: SessionMock())
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .cantAwaitRequestWithSettedCallbacks)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_throwLegacyError_whenRequestFails() async {
        // Given
        let session = SessionMock()
        let expectedError = VKError.authorizationFailed
        session.onSend = { method in
            guard let onError = method.toRequest().callbacks.onError else {
                return XCTFail("Expected error callback")
            }
            onError(expectedError)
        }

        // When
        do {
            _ = try await APIScope.Users.get(.empty).send(in: session)
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), expectedError)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_forwardProgress_whenSessionReportsProgress() async throws {
        // Given
        let session = SessionMock()
        let expectedCurrent: Int64 = 1
        let expectedTotal: Int64 = 2
        session.onSend = { method in
            guard let onProgress = method.toRequest().callbacks.onProgress else {
                return XCTFail("Expected progress callback")
            }
            onProgress(.sent(current: expectedCurrent, of: expectedTotal))
        }
        let stream = APIScope.Users.get(.empty).sendWithProgress(in: session)
        var iterator = stream.makeAsyncIterator()

        // When
        guard case let .progress(.sent(actualCurrent, actualTotal))? = try await iterator.next() else {
            return XCTFail("Expected progress")
        }

        // Then
        XCTAssertEqual(actualCurrent, expectedCurrent)
        XCTAssertEqual(actualTotal, expectedTotal)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_returnResponse_whenSessionSucceeds() async throws {
        // Given
        let session = SessionMock()
        let expectedData = Data([1, 2, 3])
        session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected success callback")
            }
            do {
                try onSuccess(expectedData)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        var iterator = APIScope.Users.get(.empty).sendWithProgress(in: session).makeAsyncIterator()

        // When
        guard case let .response(actualData)? = try await iterator.next() else {
            return XCTFail("Expected response")
        }

        // Then
        XCTAssertEqual(actualData, expectedData)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_finish_whenResponseIsReceived() async throws {
        // Given
        let session = SessionMock()
        session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected success callback")
            }
            do {
                try onSuccess(Data())
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        var iterator = APIScope.Users.get(.empty).sendWithProgress(in: session).makeAsyncIterator()

        // When
        _ = try await iterator.next()
        let nextEvent = try await iterator.next()

        // Then
        XCTAssertNil(nextEvent)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_throwLegacyError_whenRequestFails() async {
        // Given
        let session = SessionMock()
        let expectedError = VKError.authorizationFailed
        session.onSend = { method in
            guard let onError = method.toRequest().callbacks.onError else {
                return XCTFail("Expected error callback")
            }
            onError(expectedError)
        }
        var iterator = APIScope.Users.get(.empty).sendWithProgress(in: session).makeAsyncIterator()

        // When
        do {
            _ = try await iterator.next()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), expectedError)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_throwCallbacksError_whenProgressCallbackIsSet() async {
        // Given
        let request = APIScope.Users.get(.empty).toRequest()
        request.callbacks.onProgress = { _ in }
        var iterator = request.toMethod().sendWithProgress(in: SessionMock()).makeAsyncIterator()

        // When
        do {
            _ = try await iterator.next()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .cantAwaitRequestWithSettedCallbacks)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_cancelLegacyTask_whenTaskIsCancelled() async {
        // Given
        let session = SessionMock()
        let task = TaskMock()
        let requestSent = expectation(description: "request sent")
        let taskCancelled = expectation(description: "task cancelled")
        session.task = task
        session.onSend = { _ in
            requestSent.fulfill()
        }
        task.onCancel = {
            taskCancelled.fulfill()
        }

        let requestTask = Swift.Task {
            do {
                _ = try await APIScope.Users.get(.empty).send(in: session)
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [requestSent], timeout: 1)
        requestTask.cancel()
        await fulfillment(of: [taskCancelled], timeout: 1)

        // Then
        XCTAssertEqual(task.cancelCallCount, 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_keepCancellationError_whenResponseArrivesLate() async {
        // Given
        let session = SessionMock()
        let requestSent = expectation(description: "request sent")
        var completeRequest: ((Data) throws -> Void)?
        session.onSend = { method in
            completeRequest = method.toRequest().callbacks.onSuccess
            requestSent.fulfill()
        }
        let requestTask = Swift.Task { () -> Error? in
            do {
                _ = try await APIScope.Users.get(.empty).send(in: session)
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [requestSent], timeout: 1)
        requestTask.cancel()
        let actualError = await requestTask.value
        guard let completeRequest else {
            return XCTFail("Expected request completion")
        }
        do {
            try completeRequest(Data([1, 2, 3]))
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_notCancelTask_whenResponseArrivesBeforeTaskAttachment() async throws {
        // Given
        let session = SessionMock()
        let task = TaskMock()
        let expectedData = Data([1, 2, 3])
        session.task = task
        session.onSend = { method in
            guard let onSuccess = method.toRequest().callbacks.onSuccess else {
                return XCTFail("Expected success callback")
            }
            do {
                try onSuccess(expectedData)
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        let actualData = try await APIScope.Users.get(.empty).send(in: session)

        // Then
        XCTAssertEqual(actualData, expectedData)
        XCTAssertEqual(task.cancelCallCount, 0)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_cancelLegacyTask_whenCancelledBeforeTaskAttachment() async {
        // Given
        let session = SessionMock()
        let task = TaskMock()
        let requestSent = expectation(description: "request sent")
        let taskCancelled = expectation(description: "task cancelled")
        let allowTaskAttachment = DispatchSemaphore(value: 0)
        session.task = task
        session.onSend = { _ in
            requestSent.fulfill()
        }
        session.beforeReturningTask = {
            allowTaskAttachment.wait()
        }
        task.onCancel = {
            taskCancelled.fulfill()
        }
        defer { allowTaskAttachment.signal() }

        let requestTask = Swift.Task {
            do {
                _ = try await APIScope.Users.get(.empty).send(in: session)
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [requestSent], timeout: 1)
        requestTask.cancel()
        allowTaskAttachment.signal()
        await fulfillment(of: [taskCancelled], timeout: 1)

        // Then
        XCTAssertEqual(task.cancelCallCount, 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSend_cancelLegacyTaskOnce_whenCancelledTwice() async {
        // Given
        let session = SessionMock()
        let task = TaskMock()
        let requestSent = expectation(description: "request sent")
        let taskCancelled = expectation(description: "task cancelled")
        session.task = task
        session.onSend = { _ in
            requestSent.fulfill()
        }
        task.onCancel = {
            taskCancelled.fulfill()
        }

        let requestTask = Swift.Task {
            do {
                _ = try await APIScope.Users.get(.empty).send(in: session)
            }
            catch is CancellationError {
                // Expected after cancellation.
            }
            catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        // When
        await fulfillment(of: [requestSent], timeout: 1)
        requestTask.cancel()
        requestTask.cancel()
        await fulfillment(of: [taskCancelled], timeout: 1)

        // Then
        XCTAssertEqual(task.cancelCallCount, 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncSendWithProgress_cancelLegacyTask_whenConsumerIsCancelled() async {
        // Given
        let session = SessionMock()
        let task = TaskMock()
        let requestSent = expectation(description: "request sent")
        let taskCancelled = expectation(description: "task cancelled")
        session.task = task
        session.onSend = { _ in requestSent.fulfill() }
        task.onCancel = { taskCancelled.fulfill() }

        let streamConsumer = Swift.Task {
            var iterator = APIScope.Users.get(.empty).sendWithProgress(in: session).makeAsyncIterator()
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
        await fulfillment(of: [requestSent], timeout: 1)
        streamConsumer.cancel()
        await fulfillment(of: [taskCancelled], timeout: 1)

        // Then
        XCTAssertEqual(task.cancelCallCount, 1)
    }
    #endif
}
