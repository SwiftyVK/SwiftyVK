import Foundation

#if compiler(>=5.5)
/// Resolves async continuation once and handles cancellation of callback operation.
@available(iOS 13.0, macOS 10.15, *)
final class ContinuationBox<Value> {

    private enum State {
        case pending
        case resolved
        case cancelled
    }

    private let lock: Lock = MultiplatrormLock()
    private var state = State.pending
    private var continuation: CheckedContinuation<Value, Error>?
    private var onCancel: (() -> Void)?

    func begin(with continuation: CheckedContinuation<Value, Error>) -> Bool {
        let shouldBegin = lock.perform {
            guard case .pending = state, self.continuation == nil else {
                return false
            }

            self.continuation = continuation
            return true
        }

        guard shouldBegin else {
            continuation.resume(throwing: CancellationError())
            return false
        }

        return true
    }

    func shouldStartOperation() -> Bool {
        lock.perform {
            guard case .pending = state else {
                return false
            }

            return continuation != nil
        }
    }

    /// Registers handler which is called when continuation is cancelled.
    func registerCancellation(_ handler: @escaping () -> Void) {
        let handlerToRun = lock.perform { () -> (() -> Void)? in
            switch state {
            case .pending:
                onCancel = handler
                return nil
            case .cancelled:
                return handler
            case .resolved:
                return nil
            }
        }

        handlerToRun?()
    }

    func succeed(with value: Value) {
        resolve(with: .success(value))
    }

    func fail(with error: Error) {
        resolve(with: .failure(error))
    }

    func cancel() {
        let result = lock.perform { () -> (CheckedContinuation<Value, Error>?, (() -> Void)?)? in
            guard case .pending = state else {
                return nil
            }

            state = .cancelled
            defer {
                continuation = nil
                onCancel = nil
            }
            return (continuation, onCancel)
        }

        guard let (continuation, onCancel) = result else {
            return
        }

        onCancel?()
        continuation?.resume(throwing: CancellationError())
    }

    private func resolve(with result: Result<Value, Error>) {
        let continuation = lock.perform { () -> CheckedContinuation<Value, Error>? in
            guard case .pending = state else {
                return nil
            }

            state = .resolved
            defer {
                self.continuation = nil
                onCancel = nil
            }
            return self.continuation
        }

        continuation?.resume(with: result)
    }
}
#endif
