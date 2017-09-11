import Foundation

protocol LongPollTask: OperationConvertible {}

final class LongPollTaskImpl: Operation, LongPollTask {
    
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
        data: LongPollTaskData
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
                guard let strongSelf = self, !strongSelf.isCancelled else { return }
                guard let response = try? JSON(data: data) else {
                    strongSelf.semaphore.signal()
                    return
                }
                
                if response.forcedInt("failed") > 0 {
                    strongSelf.onKeyExpired()
                    strongSelf.semaphore.signal()
                }
                else {
                    let newTs = response.forcedString("ts")
                    let updates: [Any] = response.array("updates") ?? []
                    
                    strongSelf.onResponse(updates.map { JSON(value: $0) })
                    
                    strongSelf.repeatQueue.async {
                        strongSelf.update(ts: newTs)
                    }
                }
            }
            .onError { [weak self] _ in
                guard let strongSelf = self, !strongSelf.isCancelled else { return }
                
                Thread.sleep(forTimeInterval: strongSelf.delayOnError)
                guard !strongSelf.isCancelled else { return }
                strongSelf.update(ts: ts)
            }
            .send(in: session)
    }
    
    override func cancel() {
        super.cancel()
        currentTask?.cancel()
        semaphore.signal()
    }
}

struct LongPollTaskData {
    let server: String
    let startTs: String
    let lpKey: String
    let onResponse: ([JSON]) -> ()
    let onKeyExpired: () -> ()
}
