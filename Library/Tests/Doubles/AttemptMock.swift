@testable import SwiftyVK

final class AttemptMock: Operation, Attempt {
    
    var runTime = 0.01
    
    private var completion: (() -> ())?
    
    convenience init(completion: (() -> ())? = nil) {
        
        self.init(
            request: URLRequest(url: URL(string: "http://test")!),
            session: URLSessionMock(),
            callbacks: AttemptCallbacks(
                onFinish: { _ in },
                onSent: { _,_  in },
                onRecive: { _,_  in }
            )
        )
        
        self.completion = completion
    }
    
    init(request: URLRequest, session: VKURLSession, callbacks: AttemptCallbacks) {
        super.init()
    }
    
    func toOperation() -> Operation {
        return self
    }
    
    override func main() {
        Thread.sleep(forTimeInterval: runTime)
        completion?()
    }
}
