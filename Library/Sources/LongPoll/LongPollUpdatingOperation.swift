import Foundation

protocol LongPollUpdatingOperation: OperationConvertible {}

final class LongPollUpdatingOperationImpl: Operation, LongPollUpdatingOperation {
    
    private weak var session: Session?
    private let server: String
    private var startTs: String
    private let lpKey: String
    private let delayOnError: TimeInterval
    private let onResponse: ([JSON]) -> ()
    private let onKeyExpired: () -> ()
    private var currentTask: Task?
    private let semaphore = DispatchSemaphore(value: 0)
    private let repeatQueue = DispatchQueue.global(qos: .utility)
    
    init(
        session: Session?,
        delayOnError: TimeInterval,
        data: LongPollOperationData
        ) {
        self.session = session
        self.server = data.server
        self.lpKey = data.lpKey
        self.startTs = data.startTs
        self.delayOnError = delayOnError
        self.onResponse = data.onResponse
        self.onKeyExpired = data.onKeyExpired
    }
    
    override func main() {
        update(ts: startTs)
        semaphore.wait()
    }
    
    private func update(ts: String) {
        guard !isCancelled, let session = session else { return }
        
        currentTask = Request(type: .url("https://\(server)?act=a_check&key=\(lpKey)&ts=\(ts)&wait=25&mode=106"))
            .toMethod()
            .configure(with: Config(attemptsMaxLimit: .limited(1), attemptTimeout: 30, handleErrors: false))
            .onSuccess { [weak self] data in
                guard let `self` = self, !self.isCancelled else { return }
                guard let response = try? JSON(data: data) else {
                    self.semaphore.signal()
                    return
                }
                
                if response.forcedInt("failed") > 0 {
                    self.onKeyExpired()
                    self.semaphore.signal()
                }
                else {
                    let newTs = response.forcedString("ts")
                    let updates: [Any] = response.array("updates") ?? []
                    
                    self.onResponse(updates.map { JSON(value: $0) })
                    
                    self.repeatQueue.async {
                        self.update(ts: newTs)
                    }
                }
            }
            .onError { [weak self] _ in
                guard let `self` = self, !self.isCancelled else { return }
                
                Thread.sleep(forTimeInterval: self.delayOnError)
                guard !self.isCancelled else { return }
                self.update(ts: ts)
            }
            .send(in: session)
    }
    
    override func cancel() {
        super.cancel()
        currentTask?.cancel()
        semaphore.signal()
    }
}

struct LongPollOperationData {
    let server: String
    let startTs: String
    let lpKey: String
    let onResponse: ([JSON]) -> ()
    let onKeyExpired: () -> ()
}
