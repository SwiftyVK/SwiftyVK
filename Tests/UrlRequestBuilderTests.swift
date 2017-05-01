import XCTest
@testable import SwiftyVK

final class UrlRequestBuilderTests: XCTestCase {
    
    private var builder: UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderMock(),
            bodyBuilder: BodyBuilderMock()
        )
    }
    
    private func makeUrlRequestFrom(
        request: Request.Raw = .api(method: "", parameters: .empty),
        httpMethod: HttpMethod = .GET,
        timeout: TimeInterval = 0
        ) throws -> URLRequest {
        return try builder.make(from:request, httpMethod: httpMethod, timeout: timeout)
    }
    
    func test_requestTimeout() {
        // Given
        let timeout: TimeInterval = 10
        
        // When
        let sample = try! makeUrlRequestFrom(timeout: timeout).timeoutInterval
        
        // Then
        XCTAssertEqual(sample, timeout)
    }
    
    func test_apiUrl() {
        // Given
        let methodName = "test.method"
        
        // When
        let sample = try! makeUrlRequestFrom(request: .api(method: methodName, parameters: .empty)).url!
        
        // Then
        XCTAssertEqual(sample.scheme, "https")
        XCTAssertEqual(sample.host, "api.vk.com")
        XCTAssertEqual(sample.path, "/method/" + methodName)
        XCTAssertEqual(sample.query, "parameters")

    }
    
    func test_apiGetRequestHttpMethod() {
        // Given
        let httpMethod = HttpMethod.GET
        
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: httpMethod).httpMethod!
        
        // Then
        XCTAssertEqual(sample, httpMethod.rawValue)
    }
    
    func test_apiPostRequestHttpMethod() {
        // Given
        let httpMethod = HttpMethod.POST
        
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: httpMethod).httpMethod!
        
        // Then
        XCTAssertEqual(sample, httpMethod.rawValue)
    }
    
    func test_apiGetRequestHeaders() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: .GET).allHTTPHeaderFields!
        
        // Then
        XCTAssertTrue(sample.isEmpty)
    }
    
    func test_apiPostRequestHeaders() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: .POST).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample.count, 1)
        XCTAssertEqual(sample["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
    }
    
    func test_uploadRequestUrl() {
        // Given
        let url = "https://test.com"
        
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [])).url!.absoluteString
        
        // Then
        XCTAssertEqual(sample, url)
    }
    
    func test_uploadRequestWrongUrl() {
        // Given
        
        do {
            // When
            let _ = try makeUrlRequestFrom(request: .upload(url: "", media: []))
            XCTFail("Test should be failed")
        } catch let error {
            // Then
            XCTAssertEqual(error as! RequestError, .wrongUrl)
        }
    }
    
    func test_uploadRequestHttpMethod() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [])).httpMethod!
        
        // Then
        XCTAssertEqual(sample, "POST")
    }
    
    func test_uploadRequestHeaders() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [])).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample.count, 3)
        XCTAssertEqual(sample["Content-Type"], "multipart/form-data;  boundary=boundary")
        XCTAssertEqual(sample["Accept-Language"], "")
        XCTAssertEqual(sample["Content-Transfer-Encoding"], "8bit")
    }
    
    func test_customRequestUrl() {
        // Given
        let url = "https://test.com"
        
        // When
        let sample = try! makeUrlRequestFrom(request: .url("https://test.com")).url!.absoluteString
        
        // Then
        XCTAssertEqual(sample, url)
    }
    
    func test_customRequestWrongUrl() {
        // Given
        
        do {
            // When
            let _ = try makeUrlRequestFrom(request: .url(""))
            XCTFail("Test should be failed")
        } catch let error {
            // Then
            XCTAssertEqual(error as! RequestError, .wrongUrl)
        }
    }
    
    func test_customRequestHttpMethod() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(request: .url("https://test.com")).httpMethod!
        
        // Then
        XCTAssertEqual(sample, "GET")
    }
    
    func test_customRequestHeaders() {
        // Given
        
        // When
        let sample = try! makeUrlRequestFrom(request: .url("https://test.com")).allHTTPHeaderFields!
        
        // Then
        XCTAssertTrue(sample.isEmpty)
    }
}
