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
    var onVkLogInDidSuccess: ((Session, [String : String]) -> ())?
    var onVkLogInDidFail: ((Session, Error) -> ())?
    var onVkDidLogOut: ((Session) -> ())?
    
    
    func vkWillPresentView() -> Displayer? {
        return onVkWillPresentView?()
    }
    
    func vkWillLogIn(in session: Session) -> Scopes {
        return onVkWillLogIn?(session) ?? Scopes()
    }
    
    func vkLogInDidSuccess(in session: Session, with parameters: [String : String]) {
        onVkLogInDidSuccess?(session, parameters)
    }
    
    func vkLogInDidFail(in session: Session, with error: Error) {
        onVkLogInDidFail?(session, error)
    }
    
    func vkDidLogOut(in session: Session) {
        onVkDidLogOut?(session)
    }
}
