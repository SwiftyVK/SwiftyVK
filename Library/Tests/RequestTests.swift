import Foundation
import XCTest
@testable import SwiftyVK

final class RequestTests: XCTestCase {
    
    func test_upload_isUploading() {
        // When
        let request = Request(type: .upload(url: "", media: [], partType: .file))
        // Then
        XCTAssertTrue(request.isUploading)
    }
    
    func test_api_isNotUploading() {
        // When
        let request = Request(type: .api(method: "", parameters: [:]))
        // Then
        XCTAssertFalse(request.isUploading)
    }
    
    func test_url_isNotUploading() {
        // When
        let request = Request(type: .url(""))
        // Then
        XCTAssertFalse(request.isUploading)
    }
    
    func test_upload_isCanSentConcurrently() {
        // When
        let request = Request(type: .upload(url: "", media: [], partType: .file))
        // Then
        XCTAssertTrue(request.canSentConcurrently)
    }
    
    func test_url_isCanSentConcurrently() {
        // When
        let request = Request(type: .url(""))
        // Then
        XCTAssertTrue(request.canSentConcurrently)
    }
    
    func test_api_isNotCanSentConcurrently() {
        // When
        let request = Request(type: .api(method: "", parameters: [:]))
        // Then
        XCTAssertFalse(request.canSentConcurrently)
    }
    
    func test_nextRequest() {
        // GIven
        let data = String("testsData").data(using: .utf8)!
        let data2 = String("testsData2").data(using: .utf8)!

        
        // When
        let request = Request(type: .url(""), config: Config(apiVersion: "1"))
        
        request.add {
            XCTAssertEqual($0, data)
            return Request(type: .url(""), config: Config(apiVersion: "2")).toMethod()
        }
        
        request.add {
            XCTAssertEqual($0, data2)
            return Request(type: .url(""), config: Config(apiVersion: "3")).toMethod()
        }

        let nextRequest = (try? request.next(with: data)) ?? nil
        let doubleNextRequest = (try? nextRequest?.next(with: data2)) ?? nil
        let notExistedRequest = (try? request.next(with: data)) ?? nil

        // Then
        XCTAssertEqual(request.config.apiVersion, "1")
        XCTAssertEqual(nextRequest?.config.apiVersion, "2")
        XCTAssertEqual(doubleNextRequest?.config.apiVersion, "3")
        XCTAssertNil(notExistedRequest)
    }
}
