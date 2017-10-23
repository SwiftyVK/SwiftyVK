@testable import SwiftyVK

final class VKStack {
    static let delegate = SwiftyVKDelegateMock()
    
    static func mock() {
        if VK.dependenciesType != DependenciesHolderMock.self {
            VK.dependenciesType = DependenciesHolderMock.self
            VK.setUp(appId: "", delegate: delegate)
        }
    }    
}
