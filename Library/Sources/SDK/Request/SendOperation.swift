//
//  SendOperation.swift
//  SwiftyVK
//
//  Created by Алексей Кудрявцев on 28.09.16.
//
//

import Foundation



private let restrictedQueue = OperationQueue()
private let freeQueue = OperationQueue()
private let Queue = OperationQueue()
private let session = URLSession(configuration: .default, delegate: connectionDelegate, delegateQueue: nil)
private let connectionDelegate = ConnectionDelegate()
private var connections = [URLSessionTask : SendOperation]()



class SendOperation : Operation {
    let request: Request
    let task: URLSessionTask
    let semaphore = DispatchSemaphore(value: 0)
    

    
    private func send(request: Request) -> SendOperation {
        let operation = SendOperation(request: request)
        
        if request.isAPI {
            restrictedQueue.addOperation(operation)
        }
        else {
            freeQueue.addOperation(operation)
        }
        
        return operation
    }
    
    
    
    private init(request _request: Request) {
        request = _request
        task = session.dataTask(with: _request.urlRequest) {data, response, error in
            if let data = data {
                request.response.create(data)
            }
            else if let error = error {
                request.response.setError(VKError(error: error as NSError, request: request))
            }
            else {
                
            }
            
            self.finish()
        }
        
        
        connections[task] = self
    }
    
    
    
    override func main() {
        task.resume()
        semaphore.wait()
    }
    
    
    
    override func cancel() {
        task.cancel()
        super.cancel()
        finish()
    }
    
    
    
    private func finish() {
        connections.removeValue(forKey: task)
        semaphore.signal()
    }
}




class ConnectionDelegate : NSObject, URLSessionTaskDelegate {
}
