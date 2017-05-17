import XCTest
@testable import SwiftyVK

class BaseTestCase: XCTestCase {
 
    let dependencyBoxMock = DependencyBoxMock()
    
    override func setUp() {
        VK.sessions = dependencyBoxMock.sessionManager
        super.setUp()
    }
}
