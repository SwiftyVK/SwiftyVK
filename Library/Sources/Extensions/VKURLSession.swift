import Foundation

protocol VKURLSession {
    var configuration: URLSessionConfiguration { get }
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
        ) -> VKURLSessionTask

    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?)
}

extension URLSession: VKURLSession {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> VKURLSessionTask {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionTask
    }
    
    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?, response: URLResponse?, error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let urlSession = URLSession(configuration: configuration)
        let task: URLSessionTask = urlSession.dataTask(
            with: URLRequest(url: url),
            completionHandler: { taskData, taskResponse, taskError in
                data = taskData
                response = taskResponse
                error = taskError
                semaphore.signal()
            }
        )
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + 30)
        return (data, response, error)
    }
}
