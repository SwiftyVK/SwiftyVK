import Foundation

extension DispatchQueue {
    
    static func anywayOnMain<T>(_ clousure: () throws -> T) rethrows -> T {
        guard Thread.isMainThread else {
            return try main.sync(execute: clousure)
        }
        
        return try clousure()
    }
}
