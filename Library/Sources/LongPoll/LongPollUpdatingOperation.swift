import Foundation

protocol LongPollUpdatingOperation: OperationConvertible {}

final class LongPollUpdatingOperationImpl: Operation, LongPollUpdatingOperation {
    
    private weak var session: Session?
    private let server: String
    private var startTs: String
    private let lpKey: String
    private let delayOnError: TimeInterval
    private let onResponse: (JSON) -> ()
    private let onKeyExpired: () -> ()
    private var currentTask: Task?
    private let semaphore = DispatchSemaphore(value: 0)
    
    init(
        session: Session?,
        server: String,
        lpKey: String,
        startTs: String,
        delayOnError: TimeInterval,
        onResponse: @escaping (JSON) -> (),
        onKeyExpired: @escaping () -> ()
        ) {
        self.server = server
        self.lpKey = lpKey
        self.startTs = startTs
        self.delayOnError = delayOnError
        self.onResponse = onResponse
        self.onKeyExpired = onKeyExpired
        self.session = session
    }
    
    override func main() {
        update(ts: startTs)
        semaphore.wait()
    }
    
    private func update(ts: String) {
        guard !isCancelled else { return }
        
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
                    self.onResponse(response.json("updates"))

                    DispatchQueue.global().async {
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
