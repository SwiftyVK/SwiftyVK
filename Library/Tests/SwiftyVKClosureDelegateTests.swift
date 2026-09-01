import XCTest
@testable import SwiftyVK

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
final class SwiftyVKClosureDelegateTests: XCTestCase {

    func test_tokenEventsStream_yieldCreatedEvent_whenTokenIsCreated() async {
        // Given
        let tokenEvents = VKTokenEventsStream()
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .stream(tokenEvents)
        )
        var iterator = tokenEvents.stream.makeAsyncIterator()

        // When
        delegate.vkTokenCreated(for: "created", info: ["id": "1"])

        // Then
        guard case let .created(sessionId, info)? = await iterator.next() else {
            return XCTFail("Expected created event")
        }
        XCTAssertEqual(sessionId, "created")
        XCTAssertEqual(info, ["id": "1"])
    }

    func test_tokenEventsStream_yieldUpdatedEvent_whenTokenIsUpdated() async {
        // Given
        let tokenEvents = VKTokenEventsStream()
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .stream(tokenEvents)
        )
        var iterator = tokenEvents.stream.makeAsyncIterator()

        // When
        delegate.vkTokenUpdated(for: "updated", info: ["id": "2"])

        // Then
        guard case let .updated(sessionId, info)? = await iterator.next() else {
            return XCTFail("Expected updated event")
        }
        XCTAssertEqual(sessionId, "updated")
        XCTAssertEqual(info, ["id": "2"])
    }

    func test_tokenEventsStream_yieldRemovedEvent_whenTokenIsRemoved() async {
        // Given
        let tokenEvents = VKTokenEventsStream()
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .stream(tokenEvents)
        )
        var iterator = tokenEvents.stream.makeAsyncIterator()

        // When
        delegate.vkTokenRemoved(for: "removed")

        // Then
        guard case let .removed(sessionId)? = await iterator.next() else {
            return XCTFail("Expected removed event")
        }
        XCTAssertEqual(sessionId, "removed")
    }

    func test_callback_callOnce_whenTokenIsRemoved() {
        // Given
        var callCount = 0
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .callback { _ in callCount += 1 }
        )

        // When
        delegate.vkTokenRemoved(for: "removed")

        // Then
        XCTAssertEqual(callCount, 1)
    }

    func test_tokenEventsStream_finish_whenDelegateFinishesEvents() async {
        // Given
        let tokenEvents = VKTokenEventsStream()
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .stream(tokenEvents)
        )
        var iterator = tokenEvents.stream.makeAsyncIterator()

        // When
        delegate.finishTokenEvents()

        // Then
        let nextEvent = await iterator.next()
        XCTAssertNil(nextEvent)
    }

    func test_scopeProvider_returnScopes_whenDelegateRequestsScopes() {
        // Given
        let expectedScopes: Scopes = [.friends, .messages]
        var requestedSessionId: String?
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { sessionId in
                requestedSessionId = sessionId
                return expectedScopes
            },
            onViewNeedsToPresent: { _ in },
            tokenEvents: nil
        )

        // When
        let scopes = delegate.vkNeedsScopes(for: "session")

        // Then
        XCTAssertEqual(requestedSessionId, "session")
        XCTAssertEqual(scopes.rawValue, expectedScopes.rawValue)
    }

    func test_onViewNeedsToPresent_callOnce_whenDelegateRequestsPresentation() {
        // Given
        let onViewNeedsToPresentCalled = expectation(description: "onViewNeedsToPresent called")
        onViewNeedsToPresentCalled.assertForOverFulfill = true
        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in onViewNeedsToPresentCalled.fulfill() },
            tokenEvents: nil
        )

        // When
        delegate.vkNeedToPresent(viewController: VKViewController())

        // Then
        wait(for: [onViewNeedsToPresentCalled], timeout: 1)
    }
}
#endif
