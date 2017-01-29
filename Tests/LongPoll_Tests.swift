import XCTest
@testable import SwiftyVK



class LongPool_Tests: VKTestCase {
    
    func test_longPoll() {
        VK.logOut()
        VK.LP.start()
        XCTAssertFalse(VK.LP.isActive)
        
        VK.logInWith(rawToken: "1234567890", expiresIn: 9_999_999_999)
        Stubs.LongPoll.normalFlow()
        
        expectation(forNotification: VK.LP.notifications.type0.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type1.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type2.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type3.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type4.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type6.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type7.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type8.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type9.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type51.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type61.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type62.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type70.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.type80.rawValue, object: nil, handler: nil)
        expectation(forNotification: VK.LP.notifications.typeAll.rawValue, object: nil, handler: nil)
        
        VK.LP.start()
        waitForExpectations(timeout: 60) {_ in}
        
        XCTAssertTrue(VK.LP.isActive)
        VK.LP.stop()
        
        VK.logOut()
    }
}
