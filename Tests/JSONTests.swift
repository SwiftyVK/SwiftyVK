import Foundation
import XCTest
@testable import SwiftyVK

class JSONTests: XCTestCase {
    
    func test_init_whenDataIsNil() {
        XCTAssertNil(JSON(data: nil).value)
    }
    
    func test_init_whenDataIsIncorrect() {
        XCTAssertNil(JSON(data: Data()).value)
    }
    
    func test_init_whenDataIsCorrect() {

        // When
        let json = JSON(data: "[]".data(using: .utf8))
        // Then
        XCTAssertNotNil(json.value)
    }
    
    func test_containerParsing_array() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Any? = json["0"]
        // Then
        XCTAssertNotNil(value)
    }
    
    func test_containerParsing_dict() {
        // When
        let json = JSON(data: "{\"test\": 1}".data(using: .utf8))
        let value: Any? = json["test"]
        // Then
        XCTAssertNotNil(value)
    }
    
    func test_containerParsing_enclosedArrayParsing() {
        // When
        let json = JSON(data: "[[1]]".data(using: .utf8))
        let value: Any? = json["0,0"]
        // Then
        XCTAssertNotNil(value)
    }
    
    func test_containerParsing_enclosedDictParsing() {
        // When
        let json = JSON(data: "[{\"test\": 1}]".data(using: .utf8))
        let value: Any? = json["0,test"]
        // Then
        XCTAssertNotNil(value)
    }
    
    func test_containerParsing_whenPathIsLong() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Any? = json["0,0,0,0,0"]
        // Then
        XCTAssertNil(value)
    }
    
    func test_containerParsing_whenPathComponentIsEmpty() {
        // When
        let json = JSON(data: "[[1]]".data(using: .utf8))
        let value: Any? = json["0, "]
        // Then
        XCTAssertNil(value)
    }
    
    func test_arrayParsing_whenIndexIncorrect() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Any? = json["1"]
        // Then
        XCTAssertNil(value)
    }
    
    func test_dataParsing_whenDataExist() {
        // When
        let json = JSON(data: "[[1]]".data(using: .utf8))
        let value: Data = json["0"]
        // Then
        XCTAssertEqual(value.count, 7)
    }
    
    func test_dataParsing_whenDataIsPrimitive() {
        // When
        let json = JSON(data: "[[1]]".data(using: .utf8))
        let value: Data = json["0,0,0"]
        // Then
        XCTAssertEqual(value.count, 0)
    }
    
    func test_arrayParsing_whenDataExist() {
        // When
        let json = JSON(data: "[[1]]".data(using: .utf8))
        let value: Array<Any> = json["0"]
        // Then
        XCTAssertEqual(value.count, 1)
    }
    
    func test_arrayParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Array<Any> = json["0"]
        // Then
        XCTAssertEqual(value.count, 0)
    }
    
    func test_dictParsing_whenDataExist() {
        // When
        let json = JSON(data: "[{\"test\": 1}]".data(using: .utf8))
        let value: Dictionary<String, Any> = json["0"]
        // Then
        XCTAssertEqual(value.count, 1)
    }
    
    func test_dictParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Dictionary<String, Any> = json["0"]
        // Then
        XCTAssertEqual(value.count, 0)
    }
    
    func test_boolParsing_whenDataExist() {
        // When
        let json = JSON(data: "[true]".data(using: .utf8))
        let value: Bool = json["0"]
        // Then
        XCTAssertTrue(value)
    }
    
    func test_boolParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Bool = json["0"]
        // Then
        XCTAssertFalse(value)
    }
    
    func test_stringParsing_whenDataExist() {
        // When
        let json = JSON(data: "[\"test\"]".data(using: .utf8))
        let value: String = json["0"]
        // Then
        XCTAssertEqual(value, "test")
    }
    
    func test_stringParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: String = json["0"]
        // Then
        XCTAssertEqual(value, "")
    }
    
    func test_intParsing_whenDataExist() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Int = json["0"]
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_intParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Int = json["0"]
        // Then
        XCTAssertEqual(value, 0)
    }
    
    func test_floatParsing_whenDataExist() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Float = json["0"]
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_floatParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Float = json["0"]
        // Then
        XCTAssertEqual(value, 0)
    }
    
    func test_doubleParsing_whenDataExist() {
        // When
        let json = JSON(data: "[1]".data(using: .utf8))
        let value: Double = json["0"]
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_doubleParsing_whenDataNotExist() {
        // When
        let json = JSON(data: "[]".data(using: .utf8))
        let value: Double = json["0"]
        // Then
        XCTAssertEqual(value, 0)
    }
    
    func test_rootParsing() {
        // When
        let json = JSON(data: "1".data(using: .utf8))
        let value: Int = json["*"]
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_nilParsing() {
        // When
        let json = JSON(data: "".data(using: .utf8))
        let value: Any? = json[""]
        // Then
        XCTAssertNil(value)
    }
}
