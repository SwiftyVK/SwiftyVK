import Foundation

@objc protocol VKURLSessionTask: ObservableObject {
    var countOfBytesReceived: Int64 { get }
    var countOfBytesSent: Int64 { get }
    var countOfBytesExpectedToSend: Int64 { get }
    var countOfBytesExpectedToReceive: Int64 { get }
    
    func resume()
    func cancel()
}

extension URLSessionTask: VKURLSessionTask {}
