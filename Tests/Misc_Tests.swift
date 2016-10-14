import XCTest
@testable import SwiftyVK


class Components_Tests: VKTestCase {
  
  
  
  func test_default_language() {
    XCTAssertNotNil(VK.config.language, "Language is not set")
    VK.config.language = "fi"
    XCTAssertEqual(VK.config.language, "fi", "Language is not \"fi\"")
    VK.config.language = "abrakadabra"
    XCTAssertEqual(VK.config.language, "fi", "Language is not correct")
    VK.config.language = nil
    XCTAssertTrue(VK.config.supportedLanguages.contains(VK.config.language!), "Unsupportd language")
  }
}
