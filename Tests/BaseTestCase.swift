import XCTest
@testable import SwiftyVK

class BaseTestCase: XCTestCase {
 
    override func setUp() {
        VK.dependencyBox = DependencyBoxMock()
        super.setUp()
    }
}
