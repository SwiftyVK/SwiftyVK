//
//  Connection_v2.swift
//  SwiftyVK
//
//  Created by Алексей Кудрявцев on 28.09.16.
//
//

import Foundation



private let queue = OperationQueue()
private let session = URLSession(configuration: .default, delegate: connectionDelegate, delegateQueue: nil)
private let connectionDelegate = ConnectionDelegate()
private let connections = [URLSessionTask : Connection_v2]()



class Connection_v2 : Operation {
    let request: Request
    let task: URLSessionTask
    let semaphore = DispatchSemaphore(value: 0)
    

    init(request _request: Request) {
        request = _request
        task = session.dataTask(with: _request.urlRequest)
        
        
    }
    
    
    
    override func main() {
        task.resume()
        semaphore.wait()
    }
    
    
    
    override func cancel() {
        task.cancel()
        super.cancel()
        semaphore.signal()
    }
}




class ConnectionDelegate : NSObject, URLSessionDelegate {
    
}
