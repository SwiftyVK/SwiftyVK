import Foundation
import XCTest
@testable import SwiftyVK

class ApiErrorTests: XCTestCase {
    
    func test_parsing_whenFormatIsCorrect() {
        guard let json = JsonReader.read("apiError.correct")?.toJson() else { return }
        
        guard let error = ApiError(json) else {
            return XCTFail("Fail to parse apiError")
        }
        
        XCTAssertEqual(error.code, 14)
        XCTAssertEqual(error.message, "Captcha needed")
        XCTAssertEqual(error.requestParams.count, 5)
        XCTAssertEqual(error.otherInfo.count, 2)
    }
    
    func test_parsing_whenNotError() {
        guard let json = JsonReader.read("response.empty")?.toJson() else { return }

        if ApiError(json) != nil {
            return XCTFail("Unexpected error")
        }
    }
    
    func test_parsing_whenErrorWithoutCode() {
        guard let json = JsonReader.read("apiError.withoutCode")?.toJson() else { return }
        
        if ApiError(json) != nil {
            return XCTFail("Unexpected error")
        }
    }
    
    func test_parsing_whenErrorWithoutMessage() {
        guard let json = JsonReader.read("apiError.withoutMessage")?.toJson() else { return }
        
        if ApiError(json) != nil {
            return XCTFail("Unexpected error")
        }
    }
    
    func test_parsing_whenResponseIsEmpty() {
        guard let json = JsonReader.read("empty")?.toJson() else { return }
        
        if ApiError(json) != nil {
            return XCTFail("Unexpected error")
        }
    }
}
