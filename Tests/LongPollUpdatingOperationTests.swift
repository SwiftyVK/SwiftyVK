import Foundation
import XCTest
@testable import SwiftyVK

class LongPollUpdatingOperationTests: XCTestCase {
    
    func test_operation_callSuccessCallback_whenGiveUpdates() {
        // Given
        var lpResponse: JSON?
        var onSuccessCallCount = 0
        var data = JsonReader.read("longPoll.updates") ?? Data()
        
        let context = makeContext(
            onResponse: { response in
                onSuccessCallCount += 1
                lpResponse = response
                data = Data()
            },
            onKeyExpired: {
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(lpResponse?.int("13,0"), 80)
        XCTAssertEqual(onSuccessCallCount, 1)
    }
    
    func test_operation_callKeyExpiredCallback_whenGiveFailedState() {
        // Given
        var onKeyExpiredCallCount = 0
        let data = JsonReader.read("longPoll.failed") ?? Data()
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onKeyExpired: {
                onKeyExpiredCallCount += 1
            }
        )
        
        context.session.onSend = { method in
            method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(onKeyExpiredCallCount, 1)
    }
    
    func test_operation_sendTwoTimesCallback_whenGiveError() {
        // Given
        var onSendCallCount = 0
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onKeyExpired: {
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            onSendCallCount += 1

            if onSendCallCount == 1 {
                method.toRequest().callbacks.onError?(.unexpectedResponse)
            }
            else {
                method.toRequest().callbacks.onSuccess?(Data())
            }
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(onSendCallCount, 2)
    }
    
    func test_operation_notCallSuccessCallback_whenGiveUpdates() {
        // Given
        let data = JsonReader.read("longPoll.updates") ?? Data()

        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onKeyExpired: {
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            context.operation.cancel()
            method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertTrue(context.operation.toOperation().isCancelled)
    }
    
    func test_operation_cancelled_whenGiveError() {
        // Given
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onKeyExpired: {
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            context.operation.cancel()
            method.toRequest().callbacks.onError?(.unexpectedResponse)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertTrue(context.operation.toOperation().isCancelled)
    }
}

private func makeContext(
    onResponse: @escaping (JSON) -> (),
    onKeyExpired: @escaping () -> ()
    ) -> (session: SessionMock, operation: LongPollUpdatingOperationImpl) {
    let session = SessionMock()
    
    let operation = LongPollUpdatingOperationImpl(
        session: session,
        delayOnError: 0,
        data: LongPoolOperationData(
            server: "",
            startTs: "",
            lpKey: "",
            onResponse: onResponse,
            onKeyExpired: onKeyExpired
        )
    )
    
    return (session, operation)
}
