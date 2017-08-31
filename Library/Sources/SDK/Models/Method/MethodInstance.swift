public class MethodInstance: SendableMethod {
    let request: Request
    
    init(_ request: Request) {
        self.request = request
    }
    
    public func toRequest() -> Request {
        return request
    }
}
