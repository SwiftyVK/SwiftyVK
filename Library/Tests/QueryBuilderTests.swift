import XCTest
@testable import SwiftyVK

final class QueryBuilderTests: XCTestCase {
    
    var builder: QueryBuilderImpl {
        return QueryBuilderImpl()
    }
    
    private func parameters(from parameters: String) -> RawParameters {
        var result = RawParameters()
        
        parameters.components(separatedBy: "&").forEach {
            let components = $0.components(separatedBy: "=")
            result[components.first!] = components.last!
        }
        
        return result
    }
    
    func test_apiVersion() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: .empty))

        // Then
        XCTAssertEqual(sample["v"], nil)
    }

    func test_language() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: .empty))
        
        // Then
        XCTAssertEqual(sample["lang"], SessionConfig.default.language.rawValue)
    }

    func test_httpsFlag() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: .empty))
        
        // Then
        XCTAssertEqual(sample["https"], "1")
    }

    func test_apiGetRequestParameters() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: [Parameter.userId.rawValue: "test"]))
        
        // Then
        XCTAssertEqual(sample[Parameter.userId.rawValue], "test")
    }
    
    func test_ignoreEmptyParameter() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: [Parameter.userId.rawValue: ""]))
        
        // Then
        XCTAssertFalse(sample.keys.contains(Parameter.userId.rawValue))
    }
    
    func test_addCaptchaParameters() {
        // When
        let sample = parameters(from: builder.makeQuery(parameters: [Parameter.userId.rawValue: ""], captcha: (sid: "sid", key: "key")))
        
        // Then
        XCTAssertEqual(sample["captcha_sid"], "sid")
        XCTAssertEqual(sample["captcha_key"], "key")
    }
    
    func test_percentEncoding() {
        // Given
        let rawMessage = " !#$&'()*+,./:;=?@[]"
        
        // When
        let encodedQuery = builder.makeQuery(parameters: [Parameter.message.rawValue: rawMessage])
        
        let encodedMesage = encodedQuery
            .components(separatedBy: "&")
            .first { $0.starts(with: "message") }?
            .components(separatedBy: "=")
            .last
        
        // Then
        XCTAssertEqual(rawMessage, encodedMesage?.removingPercentEncoding)
    }
}
