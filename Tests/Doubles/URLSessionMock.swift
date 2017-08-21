@testable import SwiftyVK

class URLSessionMock: VKURLSession {
    
    var configuration = URLSessionConfiguration.default
    var task = URLSessionTaskMock()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> VKURLSessionTask {
        return task
    }
    
    var onSynchronousDataTaskWithURL: (() -> (data: Data?, response: URLResponse?, error: Error?))?
    
    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        return onSynchronousDataTaskWithURL?() ?? (nil, nil, nil)
    }
}
