import XCTest
@testable import SwiftyVK

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
final class ContinuationBoxTests: XCTestCase {

    func test_begin_returnValue_whenBoxSucceeds() async throws {
        // Given
        let box = ContinuationBox<Int>()
        let expectedValue = 42

        // When
        let actualValue = try await withCheckedThrowingContinuation { continuation in
            XCTAssertTrue(box.begin(with: continuation))
            box.succeed(with: expectedValue)
        }

        // Then
        XCTAssertEqual(actualValue, expectedValue)
    }

    func test_begin_throwError_whenBoxFails() async {
        // Given
        let box = ContinuationBox<Int>()
        let expectedError = VKError.authorizationFailed

        // When
        let actualError = await Swift.Task { () -> Error? in
            do {
                let _: Int = try await withCheckedThrowingContinuation { continuation in
                    XCTAssertTrue(box.begin(with: continuation))
                    box.fail(with: expectedError)
                }
                return nil
            }
            catch {
                return error
            }
        }.value

        // Then
        guard let actualError else {
            return XCTFail("Expected error")
        }
        XCTAssertEqual(actualError.toVK(), expectedError)
    }

    func test_begin_throwCancellationError_whenBoxIsCancelled() async {
        // Given
        let box = ContinuationBox<Int>()
        let continuationStarted = expectation(description: "continuation started")
        let operation = makePendingOperation(box, started: continuationStarted)

        // When
        await fulfillment(of: [continuationStarted], timeout: 1)
        box.cancel()
        let actualError = await operation.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    func test_begin_throwCancellationError_whenBoxWasCancelled() async {
        // Given
        let box = ContinuationBox<Int>()
        box.cancel()

        // When
        let actualError = await Swift.Task { () -> Error? in
            do {
                let _: Int = try await withCheckedThrowingContinuation { continuation in
                    XCTAssertFalse(box.begin(with: continuation))
                }
                return nil
            }
            catch {
                return error
            }
        }.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    func test_succeed_doNothing_whenBoxWasCancelled() async {
        // Given
        let box = ContinuationBox<Int>()
        let continuationStarted = expectation(description: "continuation started")
        let operation = makePendingOperation(box, started: continuationStarted)

        // When
        await fulfillment(of: [continuationStarted], timeout: 1)
        box.cancel()
        box.succeed(with: 42)
        let actualError = await operation.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    func test_fail_doNothing_whenBoxWasCancelled() async {
        // Given
        let box = ContinuationBox<Int>()
        let continuationStarted = expectation(description: "continuation started")
        let operation = makePendingOperation(box, started: continuationStarted)

        // When
        await fulfillment(of: [continuationStarted], timeout: 1)
        box.cancel()
        box.fail(with: VKError.authorizationFailed)
        let actualError = await operation.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    func test_cancel_doNothing_whenBoxSucceeded() async throws {
        // Given
        let box = ContinuationBox<Int>()
        let expectedValue = 42

        // When
        let actualValue = try await withCheckedThrowingContinuation { continuation in
            XCTAssertTrue(box.begin(with: continuation))
            box.succeed(with: expectedValue)
            box.cancel()
        }

        // Then
        XCTAssertEqual(actualValue, expectedValue)
    }

    func test_secondSuccess_doNothing_whenBoxSucceeded() async throws {
        // Given
        let box = ContinuationBox<Int>()
        let firstValue = 42
        let secondValue = 100

        // When
        let actualValue = try await withCheckedThrowingContinuation { continuation in
            XCTAssertTrue(box.begin(with: continuation))
            box.succeed(with: firstValue)
            box.succeed(with: secondValue)
        }

        // Then
        XCTAssertEqual(actualValue, firstValue)
    }

    func test_shouldStartOperation_returnFalse_whenBoxWasCancelled() {
        // Given
        let box = ContinuationBox<Int>()
        box.cancel()

        // When
        let shouldStartOperation = box.shouldStartOperation()

        // Then
        XCTAssertFalse(shouldStartOperation)
    }

    func test_cancellationHandler_callOnce_whenBoxIsCancelledTwice() {
        // Given
        let box = ContinuationBox<Int>()
        var callCount = 0
        box.registerCancellation { callCount += 1 }

        // When
        box.cancel()
        box.cancel()

        // Then
        XCTAssertEqual(callCount, 1)
    }

    func test_cancellationHandler_callImmediately_whenRegisteredAfterCancellation() {
        // Given
        let box = ContinuationBox<Int>()
        var callCount = 0
        box.cancel()

        // When
        box.registerCancellation { callCount += 1 }

        // Then
        XCTAssertEqual(callCount, 1)
    }

    private func makePendingOperation(
        _ box: ContinuationBox<Int>,
        started: XCTestExpectation
    ) -> Swift.Task<Error?, Never> {
        Swift.Task {
            do {
                let _: Int = try await withCheckedThrowingContinuation { continuation in
                    XCTAssertTrue(box.begin(with: continuation))
                    started.fulfill()
                }
                return nil
            }
            catch {
                return error
            }
        }
    }
}
#endif
