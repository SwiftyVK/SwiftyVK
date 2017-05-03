import XCTest
@testable import SwiftyVK

final class QueryBuilderTests: XCTestCase {
    
    var builder: QueryBuilderImpl {
        return QueryBuilderImpl()
    }
    
    private func parameters(from parameters: String) -> [String: String] {
        var result = [String: String]()
        
        parameters.components(separatedBy: "&").forEach {
            let components = $0.components(separatedBy: "=")
            result[components.first!] = components.last!
        }
        
        return result
    }
    
    func test_apiVersion() {
        // When
        let sample = parameters(from: builder.makeQuery(from: .empty))

        // Then
        XCTAssertEqual(sample["v"], VK.config.apiVersion)
    }

    func test_language() {
        // When
        let sample = parameters(from: builder.makeQuery(from: .empty))
        
        // Then
        XCTAssertEqual(sample["lang"], VK.config.language!)
    }

    func test_httpsFlag() {
        // When
        let sample = parameters(from: builder.makeQuery(from: .empty))
        
        // Then
        XCTAssertEqual(sample["https"], "1")
    }

    func test_apiGetRequestParameters() {
        // When
        let sample = parameters(from: builder.makeQuery(from: [.userId: "test"]))
        
        // Then
        XCTAssertEqual(sample[VK.Arg.userId.rawValue], "test")
    }
    
    func test_ignoreNullParameter() {
        // When
        let sample = parameters(from: builder.makeQuery(from: [.userId: nil]))
        
        // Then
        XCTAssertFalse(sample.keys.contains(VK.Arg.userId.rawValue))
    }
    
    func test_addCaptchaParameters() {
        // When
        let sample = parameters(from: builder.makeQuery(from: [.userId: nil], captcha: (sid: "sid", key: "key")))
        
        // Then
        XCTAssertEqual(sample["captcha_sid"], "sid")
        XCTAssertEqual(sample["captcha_key"], "key")
    }
    
    func test_percentEncoding() {
        // Given
        let rawMessage = " !#$&'()*+,./:;=?@[]"
        
        // When
        let encodedQuery = builder.makeQuery(from: [.message: rawMessage])
        let encodedMesage = encodedQuery.components(separatedBy: "=")[1].components(separatedBy: "&")[0]
        
        // Then
        XCTAssertEqual(rawMessage, encodedMesage.removingPercentEncoding)
    }
}
