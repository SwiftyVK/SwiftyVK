import XCTest
@testable import SwiftyVK

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
final class VKTests: XCTestCase {

    private var previousDependenciesType: DependenciesHolder.Type!

    override func setUp() {
        super.setUp()
        previousDependenciesType = VK.dependenciesType
        VK.release()
        DependenciesHolderMock.lastDelegate = nil
        VK.dependenciesType = DependenciesHolderMock.self
    }

    override func tearDown() {
        VK.release()
        DependenciesHolderMock.lastDelegate = nil
        VK.dependenciesType = previousDependenciesType
        super.tearDown()
    }

    func test_setUp_retainClosureDelegate_whenDependenciesKeepDelegateWeakly() {
        // Given
        let scopeProvider: (String) -> Scopes = { _ in [] }
        let onViewNeedsToPresent: (VKViewController) -> Void = { _ in }

        // When
        VK.setUp(appId: "", scopeProvider: scopeProvider, onViewNeedsToPresent: onViewNeedsToPresent)

        // Then
        XCTAssertNotNil(DependenciesHolderMock.lastDelegate)
    }

    func test_setUp_callback_receiveTokenEvent() {
        // Given
        var receivedSessionId: String?
        VK.setUp(
            appId: "",
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .callback { event in
                guard case let .removed(sessionId) = event else {
                    return
                }

                receivedSessionId = sessionId
            }
        )

        // When
        DependenciesHolderMock.lastDelegate?.vkTokenRemoved(for: "removed")

        // Then
        XCTAssertEqual(receivedSessionId, "removed")
    }

    func test_release_finishTokenEventsStream_whenClosureDelegateIsInstalled() async {
        // Given
        let tokenEvents = VKTokenEventsStream()
        var iterator = tokenEvents.stream.makeAsyncIterator()
        VK.setUp(
            appId: "",
            scopeProvider: { _ in [] },
            onViewNeedsToPresent: { _ in },
            tokenEvents: .stream(tokenEvents)
        )

        // When
        VK.release()

        // Then
        let nextEvent = await iterator.next()
        XCTAssertNil(nextEvent)
    }
}
#endif
