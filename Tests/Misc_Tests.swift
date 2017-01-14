import XCTest
@testable import SwiftyVK


class Components_Tests: VKTestCase {
    
    func test_default_language() {
        XCTAssertNotNil(VK.config.language, "Language is not set")
        VK.config.language = "fi"
        XCTAssertEqual(VK.config.language, "fi", "Language is not \"fi\"")
        VK.config.language = "ru"
        VK.config.language = "abrakadabra"
        XCTAssertEqual(VK.config.language, "ru", "Language is not correct")
        VK.config.language = nil
        XCTAssertNotNil(VK.config.language, "Language is not set")
        XCTAssertTrue(VK.config.supportedLanguages.contains(VK.config.language!), "Unsupported language")
    }
    
    
    
    func test_percent_encoding() {
        let rawMessage = " !#$&'()*+,./:;=?@[]"
        let encodedQuery = UrlFabric.createQueryFrom(parameters: [VK.Arg.message: rawMessage])
        let encodedMesage = encodedQuery.components(separatedBy: "=")[1].components(separatedBy: "&")[0]
        XCTAssertEqual(rawMessage, encodedMesage.removingPercentEncoding)
        print(encodedMesage)
    }
}
