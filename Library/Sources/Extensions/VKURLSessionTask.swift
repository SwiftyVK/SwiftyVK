import Foundation

protocol VKURLSessionTask: ObservableObject {
    func resume()
    func cancel()
    
    var countOfBytesReceived: Int64 { get }
    var countOfBytesSent: Int64 { get }
    var countOfBytesExpectedToSend: Int64 { get }
    var countOfBytesExpectedToReceive: Int64 { get }
}

extension URLSessionTask: VKURLSessionTask {}
