protocol VKURLSession {
    var configuration: URLSessionConfiguration { get }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> VKURLSessionTask
    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?)
}

extension URLSession: VKURLSession {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> VKURLSessionTask {
        let task: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return task as VKURLSessionTask
    }
    
    func synchronousDataTaskWithURL(url: URL) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?, response: URLResponse?, error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let task: URLSessionTask = URLSession(configuration: configuration).dataTask(with: URLRequest(url: url)) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + 30)
        return (data, response, error)
    }
}
