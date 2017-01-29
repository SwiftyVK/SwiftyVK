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
    
    

    func test_scope_parsing() {
        let intScopes = 140492031
        let stringScopes = "groups,ads,questions,email,docs,notifications,pages,audio,notify,messages,stats,wall,market,offline,offers,photos,video,notes,friends,status,"
        
        let scopesFromSet: Set = [VK.Scope.ads, .audio, .docs, .email, .friends, .groups, .market, .messages, .notes, .notifications, .notify, .offers, .offline, .pages, .photos, .questions, .stats, .status, .video, .wall]
        let scopesFromInt = VK.Scope.create(from: intScopes)
        let scopesFromString = VK.Scope.create(from: stringScopes)
        
        XCTAssertEqual(Set<VK.Scope>(), scopesFromSet.subtracting(scopesFromInt))
        XCTAssertEqual(Set<VK.Scope>(), scopesFromSet.subtracting(scopesFromString))

        XCTAssertEqual(VK.Scope.toInt(scopesFromSet), intScopes)
        XCTAssertEqual(VK.Scope.toString(scopesFromSet), stringScopes)
    }
}
