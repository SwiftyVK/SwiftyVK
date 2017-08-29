@testable import SwiftyVK

class VKReachabilityMock: VKReachability {
    var isReachable = false

    var onStartNotifier: (() throws -> ())?
    
    func startNotifier() throws {
        try onStartNotifier?()
    }
}
