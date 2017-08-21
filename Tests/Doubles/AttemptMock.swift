@testable import SwiftyVK

final class AttemptMock: Operation, Attempt {
    
    private var isReallyFinished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    var delay = 0.01
    
    override var isFinished: Bool {
        return isReallyFinished
    }
    
    convenience override init() {
        
        self.init(
            request: URLRequest(url: URL(string: "http://test")!),
            timeout: 0,
            session: URLSessionMock(),
            queue: DispatchQueue.global(qos: .background),
            callbacks: AttemptCallbacks(
                onFinish: { _ in },
                onSent: { _ in },
                onRecive: { _ in }
            )
        )
    }
    
    init(request: URLRequest, timeout: TimeInterval, session: VKURLSession, queue: DispatchQueue, callbacks: AttemptCallbacks) {
        super.init()
    }
    
    override func main() {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            self.isReallyFinished = true
        }
    }
}

final class WrongAttemptMock: Attempt {
    
    convenience init() {
        self.init(
            request: URLRequest(url: URL(string: "http://test")!),
            timeout: 0,
            session: URLSessionMock(),
            queue: DispatchQueue.global(qos: .background),
            callbacks: AttemptCallbacks(
                onFinish: { _ in },
                onSent: { _ in },
                onRecive: { _ in }
            )
        )
    }
    
    init(request: URLRequest, timeout: TimeInterval, session: VKURLSession, queue: DispatchQueue, callbacks: AttemptCallbacks) {}
    
    func cancel() {}
}
