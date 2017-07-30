import Foundation
import XCTest
@testable import SwiftyVK

class ResponseTests: XCTestCase {
    
    func test_parsing_apiError() {
        guard let data = JsonReader.read("apiError.correct") else { return }
        
        let result = Response(data)
        
        switch result {
        case let .error(.api(error)):
            XCTAssertEqual(error.code, 14)
        default:
            XCTFail()
        }
    }
    
    func test_parsing_emptyResponse() {
        guard let data = JsonReader.read("response.empty") else { return }
        
        let result = Response(data)

        switch result {
        case let .success(data):
            XCTAssertEqual(data.count, 2)
        default:
            XCTFail()
        }
    }
    
    func test_parsing_emptyResult() {
        guard let data = JsonReader.read("empty") else { return }
        
        let result = Response(data)

        switch result {
        case let .success(data):
            XCTAssertEqual(data.count, 4)
        default:
            XCTFail()
        }
    }
    
    func test_parsing_wrongJson() {
        let result = Response(Data())

        switch result {
        case let .error(.request(.jsonNotParsed(error))):
            XCTAssertEqual((error as NSError).code, 3840)
        default:
            XCTFail()
        }
    }
}

