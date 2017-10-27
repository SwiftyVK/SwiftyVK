import Foundation

extension DispatchQueue {
    
    static func safelyOnMain<T>(_ clousure: () throws -> T) rethrows -> T {
        guard Thread.isMainThread else {
            return try main.sync(execute: clousure)
        }
        
        return try clousure()
    }
}
