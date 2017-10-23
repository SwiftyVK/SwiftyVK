@testable import SwiftyVK

final class URLSessionMock: VKURLSession {
    
    var configuration = URLSessionConfiguration.default
    
    var onDataTask: ((@escaping (Data?, URLResponse?, Error?) -> ()) -> VKURLSessionTask)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> VKURLSessionTask {
        return onDataTask?(completionHandler) ?? URLSessionTaskMock()
    }
    
    var onSynchronousDataTaskWithURL: (() -> (data: Data?, response: URLResponse?, error: Error?))?
    
    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        return onSynchronousDataTaskWithURL?() ?? (nil, nil, nil)
    }
}
