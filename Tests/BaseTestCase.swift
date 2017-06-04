import XCTest
@testable import SwiftyVK

class BaseTestCase: XCTestCase {
 
    var swiftyVkDelegateMock = SwiftyVKDelegateMock()
    
    override func setUp() {
        VK.prepareForUse(appId: "", delegate: swiftyVkDelegateMock)
        super.setUp()
    }
}
