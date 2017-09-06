@testable import SwiftyVK

final class AttemptMock: Operation, Attempt {
    
    private var isReallyFinished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    var runTime = 0.01
    
    override var isFinished: Bool {
        return isReallyFinished
    }
    
    private var completion: (() -> ())?
    
    convenience init(completion: (() -> ())? = nil) {
        
        self.init(
            request: URLRequest(url: URL(string: "http://test")!),
            timeout: 0,
            session: URLSessionMock(),
            callbacks: AttemptCallbacks(
                onFinish: { _ in },
                onSent: { _ in },
                onRecive: { _ in }
            )
        )
        
        self.completion = completion
    }
    
    init(request: URLRequest, timeout: TimeInterval, session: VKURLSession, callbacks: AttemptCallbacks) {
        super.init()
    }
    
    func toOperation() -> Operation {
        return self
    }
    
    override func main() {
        DispatchQueue.global().asyncAfter(deadline: .now() + runTime) { [weak self] in
            self?.isReallyFinished = true
            self?.completion?()
        }
    }
}
