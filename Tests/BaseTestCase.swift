import XCTest
@testable import SwiftyVK

class BaseTestCase: XCTestCase {
 
    var swiftyVkDelegateMock = SwiftyVKDelegateMock()
    let dependencyBoxMock = DependencyBoxMock()
    
    override func setUp() {
        VK.initializeWith(appId: "", delegate: swiftyVkDelegateMock)
        VK.sessions = dependencyBoxMock.sessionStorage
        super.setUp()
    }
}

final class SwiftyVKDelegateMock: SwiftyVKDelegate {
    
    var onVkWillPresentView: (() -> Displayer?)?
    var onVkWillLogIn: ((Session) -> Scopes)?
    var onVkDidLogOut: ((Session) -> ())?
    
    
    func vkWillPresentView() -> Displayer? {
        return onVkWillPresentView?()
    }
    
    func vkWillLogIn(in session: Session) -> Scopes {
        return onVkWillLogIn?(session) ?? Scopes()
    }
    
    func vkDidLogOut(in session: Session) {
        onVkDidLogOut?(session)
    }
}
