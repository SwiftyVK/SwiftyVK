import XCTest
@testable import SwiftyVK

final class UrlRequestFactoryTests: XCTestCase {
    
    func test_apiUrl() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request()
        
        // When
        let sample = try! factory.make(from: request).url!
        
        // Then
        XCTAssertEqual(sample.scheme, "https")
        XCTAssertEqual(sample.host, "api.vk.com")
        XCTAssertEqual(sample.path, "/method/users.get")
    }
    
    func test_apiVersion() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request()
        
        // When
        let sample = try! factory.make(from: request).url!.query!
        
        // Then
        XCTAssertTrue(sample.contains("v=\(VK.config.apiVersion)"))
    }
    
    func test_requestLanguage() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request()
        
        // When
        let sample = try! factory.make(from: request).url!.query!
        
        // Then
        XCTAssertTrue(sample.contains("lang=\(VK.config.language!)"))
    }
    
    func test_httpsFlag() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request()
        
        // When
        let sample = try! factory.make(from: request).url!.query!
        
        // Then
        XCTAssertTrue(sample.contains("https=1"))
    }
    
    func test_apiGetRequestParameters() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get([.userId: "test"]).request()
        
        // When
        let sample = try! factory.make(from: request).url!.query!
        
        // Then
        XCTAssertTrue(sample.contains("user_id=test"))
    }
    
    func test_apiPostRequestParameters() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get([.userId: "test"]).request(with: Config(httpMethod: .POST))
        
        // When
        let sample = String(data: try! factory.make(from: request).httpBody!, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(sample.contains("user_id=test"))
    }
    
    func test_apiGetRequestHttpMethod() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request()
        
        // When
        let sample = try! factory.make(from: request).httpMethod
        
        // Then
        XCTAssertEqual(sample, "GET")
    }
    
    func test_apiPostRequestHttpMethod() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request(with: Config(httpMethod: .POST))
        
        // When
        let sample = try! factory.make(from: request).httpMethod
        
        // Then
        XCTAssertEqual(sample, "POST")
    }
    
    func test_apiGetRequestHeaders() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get([.userId: "test"]).request()
        
        // When
        let sample = try! factory.make(from: request).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample, [:])
    }
    
    func test_apiPostRequestHeaders() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get([.userId: "test"]).request(with: Config(httpMethod: .POST))
        
        // When
        let sample = try! factory.make(from: request).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
    }
    
    func test_requestTimeout() {
        // Given
        let factory = UrlRequestFactoryImpl()
        let request = VK.Api.Users.get(.empty).request(with: Config(timeout: 10))
        
        // When
        let sample = try! factory.make(from: request)
        
        // Then
        XCTAssertEqual(sample.timeoutInterval, request.config.timeout)
    }
}
