@testable import SwiftyVK

final class VKStack {
    static let delegate = SwiftyVKDelegateMock()
    private static var mocks = [Request: MockResult]()
   
    static func mock(_ requestType: RequestType, fileName: String, file: StaticString = #file, line: UInt = #line) {
        guard let data = JsonReader.read(fileName, file: file, line: line) else { return }
        mock(Request(type: requestType).toMethod(), result: .result(.data(data)))
    }
    
    static func mock(_ method: SendableMethod, fileName: String, file: StaticString = #file, line: UInt = #line) {
        guard let data = JsonReader.read(fileName, file: file, line: line) else { return }
        mock(method, result: .result(.data(data)))
    }
    
    static func mock(_ method: SendableMethod, data: Data) {
        mock(method, result: .result(.data(data)))
    }
    
    static func mock(_ method: SendableMethod, error: VKError) {
        mock(method, result: .result(.error(error)))
    }
    
    static func mock(_ method: SendableMethod, clousure: @escaping () -> ()) {
        mock(method, result: .clousure(clousure))
    }
    
    private static func mock(_ method: SendableMethod, result: MockResult) {
        mockSession()
        enableMocks()
        mocks[method.toRequest()] = result
    }
    
    static func mockSession() {
        if VK.dependenciesType != DependenciesHolderMock.self {
            VK.dependenciesType = DependenciesHolderMock.self
            VK.setUp(appId: "", delegate: delegate)
        }
    }
    
    private static func enableMocks() {
        
        (VK.sessions.default as? SessionMock)?.onSend = { method in
            let request = method.toRequest()
            
            guard let result = mocks[request] else {
                mocks[request] = nil
                let error = VKError.unknown(NSError(domain: "NOT MOCKED \(request.type)", code: 0))
                request.callbacks.onError?(error)
                return
            }
            
            do {
                switch result {
                case let .result(result):
                    let data = try result.unwrap()
                    
                    if try request.next(with: data)?.toMethod().send() == nil {
                        try request.callbacks.onSuccess?(data)
                    }
                case let .clousure(clousure):
                    clousure()
                    try? request.callbacks.onSuccess?(Data())
                }
            }
            catch {
                request.callbacks.onError?(error.toVK())
            }
        }
    }
    
    static func removeAllMocks() {
        mocks.removeAll()
        (VK.sessions.default as? SessionMock)?.onSend = nil
    }
}

enum MockResult {
    case result(Result<Data, VKError>)
    case clousure(() -> ())
}
