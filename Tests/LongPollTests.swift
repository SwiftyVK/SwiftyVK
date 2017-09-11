import Foundation
import XCTest
@testable import SwiftyVK

class LongPollTests: XCTestCase {
    
    func test() {
        // Given
        let expectation = self.expectation(description: "")
        let context = makeContext()

        context.operationMaker.onMake = { _, _ in
            expectation.fulfill()
            return LongPollUpdatingOperationMock()
        }
        // When
        context.longPoll.start { events in
            
        }
        // Then
        waitForExpectations(timeout: 1)
    }
}

private func makeContext() -> (
    longPoll: LongPollImpl,
    operationMaker: LongPollUpdatingOperationMakerMock,
    connectionObserver: ConnectionObserverMock
    ) {
    let operationMaker = LongPollUpdatingOperationMakerMock()
    let connectionObserver = ConnectionObserverMock()
    
    let longPoll = LongPollImpl(
        session: SessionMock(),
        operationMaker: operationMaker,
        connectionObserver: connectionObserver
    )
    
    return (longPoll, operationMaker, connectionObserver)
}
