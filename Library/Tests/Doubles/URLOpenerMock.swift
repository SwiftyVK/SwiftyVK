@testable import SwiftyVK

final class URLOpenerMock: URLOpener {
    
    var allowCanOpenUrl = true
    
    func canOpenURL(_ url: URL) -> Bool {
        return allowCanOpenUrl
    }
    
    var allowOpenURL = true
    
    func openURL(_ url: URL) -> Bool {
        return allowOpenURL
    }
}
