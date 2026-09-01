import XCTest
@testable import SwiftyVK

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
final class ContinuationBoxRaceTests: XCTestCase {

    func test_cancelAndSuccess_resolveOnce_whenCalledConcurrently() async {
        // Given
        let iterations = 50

        // When
        var results = [Result<Int, Error>]()
        for _ in 0..<iterations {
            let result = await resolveConcurrently(
                first: { $0.cancel() },
                second: { $0.succeed(with: 42) }
            )
            results.append(result)
        }

        // Then
        for result in results {
            switch result {
            case .success(let value):
                XCTAssertEqual(value, 42)
            case .failure(let error):
                XCTAssertTrue(error is CancellationError)
            }
        }
    }

    func test_cancelAndFailure_resolveOnce_whenCalledConcurrently() async {
        // Given
        let iterations = 50

        // When
        var results = [Result<Int, Error>]()
        for _ in 0..<iterations {
            let result = await resolveConcurrently(
                first: { $0.cancel() },
                second: { $0.fail(with: VKError.authorizationFailed) }
            )
            results.append(result)
        }

        // Then
        for result in results {
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertTrue(error is CancellationError || error.toVK() == .authorizationFailed)
            }
        }
    }

    func test_cancellationHandler_callOnce_whenRegisteredAndCancelledConcurrently() {
        // Given
        let iterations = 50

        // When
        let callCounts = (0..<iterations).map { _ in
            cancellationHandlerCallCountAfterConcurrentRegistrationAndCancellation()
        }

        // Then
        for callCount in callCounts {
            XCTAssertEqual(callCount, 1)
        }
    }

    private func resolveConcurrently(
        first: @escaping (ContinuationBox<Int>) -> Void,
        second: @escaping (ContinuationBox<Int>) -> Void
    ) async -> Result<Int, Error> {
        let box = ContinuationBox<Int>()
        let continuationStarted = expectation(description: "continuation started")
        let operation = Swift.Task { () -> Result<Int, Error> in
            do {
                let value = try await withCheckedThrowingContinuation { continuation in
                    XCTAssertTrue(box.begin(with: continuation))
                    continuationStarted.fulfill()
                }
                return .success(value)
            }
            catch {
                return .failure(error)
            }
        }

        await fulfillment(of: [continuationStarted], timeout: 1)
        runConcurrently(first: { first(box) }, second: { second(box) })
        return await operation.value
    }

    private func runConcurrently(
        first: @escaping () -> Void,
        second: @escaping () -> Void
    ) {
        let ready = DispatchGroup()
        let finished = DispatchGroup()
        let start = DispatchSemaphore(value: 0)

        [first, second].forEach { operation in
            ready.enter()
            finished.enter()
            DispatchQueue.global().async {
                ready.leave()
                start.wait()
                operation()
                finished.leave()
            }
        }

        ready.wait()
        start.signal()
        start.signal()
        finished.wait()
    }

    private func cancellationHandlerCallCountAfterConcurrentRegistrationAndCancellation() -> Int {
        let box = ContinuationBox<Int>()
        let lock: Lock = MultiplatrormLock()
        var callCount = 0

        runConcurrently(
            first: {
                box.registerCancellation {
                    lock.perform { callCount += 1 }
                }
            },
            second: {
                box.cancel()
            }
        )

        return lock.perform { callCount }
    }
}
#endif
