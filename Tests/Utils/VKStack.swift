@testable import SwiftyVK

class VKStack {
    static let delegate = SwiftyVKDelegateMock()
    
    static func mock() {
        if VK.dependenciesHolderInstanceType != DependenciesHolderMock.self {
            VK.dependenciesHolderInstanceType = DependenciesHolderMock.self
            VK.prepareForUse(appId: "", delegate: delegate)
        }
    }    
}
