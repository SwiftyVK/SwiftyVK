import XCTest
@testable import SwiftyVK


class Components_Tests: VKTestCase {
  
  
  
  func test_default_language() {
    XCTAssertNotNil(VK.defaults.language, "Language is not set")
    VK.defaults.language = "fi"
    XCTAssertEqual(VK.defaults.language, "fi", "Language is not \"fi\"")
    VK.defaults.language = "abrakadabra"
    XCTAssertEqual(VK.defaults.language, "fi", "Language is not correct")
    VK.defaults.language = nil
    XCTAssertTrue(VK.defaults.supportedLanguages.contains(VK.defaults.language!), "Unsupportd language")
  }
  
  
  
  func test_request_language() {
    let req = VK.API.Users.get()
    
    XCTAssertNotNil(req.language, "Language is not set")
    req.language = "fi"
    XCTAssertEqual(req.language, "fi", "Language is not \"fi\"")
    req.language = "abrakadabra"
    XCTAssertEqual(req.language, "fi", "Language is not correct")
    req.language = nil
    XCTAssertTrue(VK.defaults.supportedLanguages.contains(req.language!), "Unsupportd language")
  }
  
  
  
//  func test_longpool() {
//    expectationForNotification(VK.LP.notifications.typeAll, object: nil, handler: nil)
//    VK.LP.start()
//    waitForExpectationsWithTimeout(60) {_ in}
//  }
}
