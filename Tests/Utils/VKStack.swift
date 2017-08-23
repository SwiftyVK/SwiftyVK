@testable import SwiftyVK

class VKStack {
    static let delegate = SwiftyVKDelegateMock()
    
    static func mock() {
        if VK.dependencyHolderInstanceType != DependencyHolderMock.self {
            VK.dependencyHolderInstanceType = DependencyHolderMock.self
            VK.prepareForUse(appId: "", delegate: delegate)
        }
    }    
}
