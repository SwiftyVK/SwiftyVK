import Foundation

#if compiler(>=5.5)
@available(iOS 13.0, macOS 10.15, *)
public enum VKTokenEvent {
    case created(sessionId: String, info: [String: String])
    case updated(sessionId: String, info: [String: String])
    case removed(sessionId: String)
}

/// Chooses one way to receive VK token lifecycle events.
@available(iOS 13.0, macOS 10.15, *)
public enum VKTokenEventsHandler {
    case callback((VKTokenEvent) -> Void)
    case stream(VKTokenEventsStream)
}

/// Delivers token lifecycle events configured with `VK.setUp`.
@available(iOS 13.0, macOS 10.15, *)
public struct VKTokenEventsStream {
    public let stream: AsyncStream<VKTokenEvent>

    private let storage: VKTokenEventsStorage

    public init(
        bufferingPolicy: AsyncStream<VKTokenEvent>.Continuation.BufferingPolicy = .unbounded
    ) {
        let storage = VKTokenEventsStorage(bufferingPolicy: bufferingPolicy)
        self.storage = storage
        self.stream = storage.stream
    }

    func yield(_ event: VKTokenEvent) {
        storage.yield(event)
    }

    func finish() {
        storage.finish()
    }
}

@available(iOS 13.0, macOS 10.15, *)
private final class VKTokenEventsStorage {
    let stream: AsyncStream<VKTokenEvent>
    private let continuation: AsyncStream<VKTokenEvent>.Continuation

    init(bufferingPolicy: AsyncStream<VKTokenEvent>.Continuation.BufferingPolicy) {
        var continuation: AsyncStream<VKTokenEvent>.Continuation?
        let stream = AsyncStream(VKTokenEvent.self, bufferingPolicy: bufferingPolicy) {
            continuation = $0
        }

        guard let unwrappedContinuation = continuation else {
            fatalError("AsyncStream must create its continuation synchronously")
        }

        self.stream = stream
        self.continuation = unwrappedContinuation
    }

    func yield(_ event: VKTokenEvent) {
        continuation.yield(event)
    }

    func finish() {
        continuation.finish()
    }
}

@available(iOS 13.0, macOS 10.15, *)
final class SwiftyVKClosureDelegate: SwiftyVKDelegate {
    private let scopeProvider: (String) -> Scopes
    private let onViewNeedsToPresent: (VKViewController) -> Void
    private let tokenEvents: VKTokenEventsHandler?

    init(
        scopeProvider: @escaping (String) -> Scopes,
        onViewNeedsToPresent: @escaping (VKViewController) -> Void,
        tokenEvents: VKTokenEventsHandler?
    ) {
        self.scopeProvider = scopeProvider
        self.onViewNeedsToPresent = onViewNeedsToPresent
        self.tokenEvents = tokenEvents
    }

    func vkNeedsScopes(for sessionId: String) -> Scopes {
        scopeProvider(sessionId)
    }

    func vkNeedToPresent(viewController: VKViewController) {
        onViewNeedsToPresent(viewController)
    }

    func vkTokenCreated(for sessionId: String, info: [String: String]) {
        notify(.created(sessionId: sessionId, info: info))
    }

    func vkTokenUpdated(for sessionId: String, info: [String: String]) {
        notify(.updated(sessionId: sessionId, info: info))
    }

    func vkTokenRemoved(for sessionId: String) {
        notify(.removed(sessionId: sessionId))
    }

    func finishTokenEvents() {
        guard case let .stream(stream)? = tokenEvents else {
            return
        }

        stream.finish()
    }

    private func notify(_ event: VKTokenEvent) {
        switch tokenEvents {
        case let .callback(handler):
            handler(event)
        case let .stream(stream):
            stream.yield(event)
        case nil:
            return
        }
    }
}
#endif
