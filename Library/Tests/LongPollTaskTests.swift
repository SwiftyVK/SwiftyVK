import Foundation
import XCTest
@testable import SwiftyVK

final class LongPollTaskTests: XCTestCase {
    
    func test_operation_callSuccessCallback_whenGiveUpdates() {
        // Given
        var lpResponse: [JSON]?
        var onSuccessCallCount = 0
        var data = JsonReader.read("longPoll.updates") ?? Data()
        
        let context = makeContext(
            onResponse: { response in
                onSuccessCallCount += 1
                lpResponse = response
                data = Data()
            },
            onError: { _ in
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(lpResponse?.last?.int("0"), 114)
        XCTAssertEqual(onSuccessCallCount, 1)
    }
    
    func test_operation_callSuccessCallback_whenGiveEmptyUpdates() {
        // Given
        var lpResponse: [JSON]?
        var onSuccessCallCount = 0
        var data = JsonReader.read("longPoll.empty") ?? Data()
        
        let context = makeContext(
            onResponse: { response in
                onSuccessCallCount += 1
                lpResponse = response
                data = Data()
        },
            onError: { _ in
                XCTFail("Response contains unexpected error")
        }
        )
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertTrue(lpResponse?.isEmpty ?? false)
        XCTAssertEqual(onSuccessCallCount, 1)
    }
    
    func test_operation_callOnErrorCallback_whenHistoryIsLostWithTs() {
        // Given
        var onErrorCallCount = 0
        let data = JsonReader.read("longPoll.failed.1.withTs") ?? Data()
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onError: { error in
                XCTAssertEqual(error, .historyMayBeLost)
                onErrorCallCount += 1
            }
        )
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(data)
            context.operation.cancel()
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(onErrorCallCount, 1)
    }
    
    func test_operation_callOnErrorCallback_whenHistoryIsLostWithoutTs() {
        // Given
        var onErrorCallCount = 0
        let data = JsonReader.read("longPoll.failed.1") ?? Data()
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onError: { error in
                XCTAssertEqual(error, .unknown)
                onErrorCallCount += 1
            }
        )
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(onErrorCallCount, 1)
    }
    
    func test_operation_callOnErrorCallback_whenConnectionIsLost() {
        // Given
        var onErrorCallCount = 0
        let data = JsonReader.read("longPoll.failed.2") ?? Data()
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onError: { error in
                XCTAssertEqual(error, .connectionInfoLost)
                onErrorCallCount += 1
            }
        )
        
        context.session.onSend = { method in
            try? method.toRequest().callbacks.onSuccess?(data)
        }
        // When
        context.operation.main()
        // Then
        XCTAssertEqual(onErrorCallCount, 1)
    }
    
    func test_operation_sendTwoTimesCallback_whenGiveError() {
        // Given
        var onSendCallCount = 0
        
        let context = makeContext(
            onResponse: { _ in
                XCTFail("Response contains unexpected updates")
            },
            onError: { _ in
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            onSendCallCount += 1

            if onSendCallCount == 1 {
                method.toRequest().callbacks.onError?(.unexpectedResponse)
            }
            else {
                try? method.toRequest().callbacks.onSuccess?(Data())
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
            onError: { _ in
                XCTFail("Response contains unexpected error")
            }
        )
        
        context.session.onSend = { method in
            context.operation.cancel()
            try? method.toRequest().callbacks.onSuccess?(data)
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
            onError: { _ in
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
    onResponse: @escaping ([JSON]) -> (),
    onError: @escaping (LongPollTaskError) -> ()
    ) -> (session: SessionMock, operation: LongPollTaskImpl) {
    let session = SessionMock()
    
    let operation = LongPollTaskImpl(
        session: session,
        delayOnError: 0,
        data: LongPollTaskData(
            server: "",
            startTs: "",
            lpKey: "",
            onResponse: onResponse,
            onError: onError
        )
    )
    
    return (session, operation)
}
