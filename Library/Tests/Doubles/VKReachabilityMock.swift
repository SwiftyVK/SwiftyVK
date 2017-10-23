@testable import SwiftyVK

final class VKReachabilityMock: VKReachability {
    var isReachable = false

    var onStartNotifier: (() throws -> ())?
    
    func startNotifier() throws {
        try onStartNotifier?()
    }
}
