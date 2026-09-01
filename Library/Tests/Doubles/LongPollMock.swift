@testable import SwiftyVK
import XCTest

final class LongPollMock: LongPoll {
    var isActive: Bool = false
    private var isStreamOpen = false

    var onStart: (() -> ())?
    var onReceiveEvents: (([LongPollEvent]) -> ())?
    var lastVersion: LongPollVersion?

    func start(version: LongPollVersion, onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        guard !isActive else { return }

        isActive = true
        lastVersion = version
        self.onReceiveEvents = onReceiveEvents
        onStart?()
    }

    @available(iOS 13.0, macOS 10.15, *)
    func eventsStream(version: LongPollVersion) -> AsyncThrowingStream<[LongPollEvent], Error> {
        return AsyncThrowingStream { continuation in
            guard !self.isActive, !self.isStreamOpen else {
                continuation.finish(throwing: VKError.longPollAlreadyObserved)
                return
            }

            self.isStreamOpen = true
            self.start(version: version) { events in
                continuation.yield(events)
            }
            continuation.onTermination = { [weak self] _ in
                self?.stopStream()
            }
        }
    }

    var onStop: (() -> ())?

    func stop() {
        guard isActive, !isStreamOpen else { return }

        isActive = false
        onStop?()
    }

    private func stopStream() {
        guard isStreamOpen else { return }

        isStreamOpen = false
        guard isActive else { return }

        isActive = false
        onStop?()
    }
}
