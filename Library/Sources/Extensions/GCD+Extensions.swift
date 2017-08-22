import Foundation

extension DispatchQueue {
    
    static func performOnMainIfNeeded<T>(_ clousure: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try clousure()
        }
        else {
            return try DispatchQueue.main.sync {
                try clousure()
            }
        }
    }
}
