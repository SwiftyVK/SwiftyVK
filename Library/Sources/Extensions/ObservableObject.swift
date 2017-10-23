import Foundation

protocol ObservableObject {
    
    func addObserver(
        _ observer: NSObject,
        forKeyPath keyPath: String,
        options: NSKeyValueObservingOptions,
        context: UnsafeMutableRawPointer?
    )
    
    func removeObserver(
        _ observer: NSObject,
        forKeyPath keyPath: String
    )
}
