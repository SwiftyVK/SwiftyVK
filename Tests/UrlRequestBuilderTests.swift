import XCTest
@testable import SwiftyVK

final class UrlRequestBuilderTests: BaseTestCase {
    
    private let queryBuilder = QueryBuilderMock()
    private let bodyBuilder = MultipartBodyBuilderMock()

    private var builder: UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: queryBuilder,
            bodyBuilder: bodyBuilder
        )
    }
    
    private func makeUrlRequestFrom(
        request: Request.Raw = .api(method: "", parameters: .empty),
        httpMethod: HttpMethod = .GET,
        timeout: TimeInterval = 0
        ) throws -> URLRequest {
        return try builder.build(
            request: request,
            httpMethod: httpMethod,
            config: Config(attemptTimeout: timeout),
            capthca: nil,
            token: nil
        )
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
        XCTAssertEqual(sample.query, queryBuilder.parameters)

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
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: .GET).allHTTPHeaderFields!
        
        // Then
        XCTAssertTrue(sample.isEmpty)
    }
    
    func test_apiPostRequestHeaders() {
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: .POST).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample.count, 1)
        XCTAssertEqual(sample["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
    }
    
    func test_apiPostRequestBody() {
        // When
        let sample = try! makeUrlRequestFrom(httpMethod: .POST).httpBody!
        
        // Then
        XCTAssertEqual(sample, queryBuilder.parameters.data(using: .utf8))
    }
    
    func test_uploadRequestUrl() {
        // Given
        let url = "https://test.com"
        
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [], partType: .file)).url!.absoluteString
        
        // Then
        XCTAssertEqual(sample, url)
    }
    
    func test_uploadRequestWrongUrl() {
        do {
            // When
            let _ = try makeUrlRequestFrom(request: .upload(url: "", media: [], partType: .file))
            XCTFail("Test should be failed")
        } catch let error {
            // Then
            XCTAssertEqual(error as! RequestError, .wrongUrl)
        }
    }
    
    func test_uploadRequestHttpMethod() {
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [], partType: .file)).httpMethod!
        
        // Then
        XCTAssertEqual(sample, "POST")
    }
    
    func test_uploadRequestHeaders() {
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [], partType: .file)).allHTTPHeaderFields!
        
        // Then
        XCTAssertEqual(sample.count, 3)
        XCTAssertEqual(sample["Content-Type"], "multipart/form-data;  boundary=boundary")
        XCTAssertEqual(sample["Accept-Language"], "")
        XCTAssertEqual(sample["Content-Transfer-Encoding"], "8bit")
    }
    
    func test_uploadPostRequestBody() {
        // When
        let sample = try! makeUrlRequestFrom(request: .upload(url: "https://test.com", media: [], partType: .file)).httpBody!
        
        // Then
        XCTAssertEqual(sample, bodyBuilder.data)
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
        // When
        let sample = try! makeUrlRequestFrom(request: .url("https://test.com")).httpMethod!
        
        // Then
        XCTAssertEqual(sample, "GET")
    }
    
    func test_customRequestHeaders() {
        // When
        let sample = try! makeUrlRequestFrom(request: .url("https://test.com")).allHTTPHeaderFields!
        
        // Then
        XCTAssertTrue(sample.isEmpty)
    }
}
