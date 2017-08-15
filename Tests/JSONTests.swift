import Foundation
import XCTest
@testable import SwiftyVK

class JSONTests: XCTestCase {
    
    func test_init_whenDataIsNil() {
        // When
        let json = try? JSON(data: nil)
        // Then
        XCTAssertNil(json)
    }
    
    func test_init_whenDataIsIncorrect() {
        // When
        let json = try? JSON(data: Data())
        // Then
        XCTAssertNil(json)
    }
    
    func test_init_whenDataIsCorrect() {
        // When
        let json = try? JSON(data: "[]".data(using: .utf8))
        // Then
        XCTAssertNotNil(json)
    }

    func test_any_isNotNil_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.any("0")
        // Then
        XCTAssertNotNil(value)
    }

    func test_any_isNotNil_whenDataIsDict() {
        // When
        let json = try! JSON(data: "{\"test\": 1}".data(using: .utf8))
        let value = json.any("test")
        // Then
        XCTAssertNotNil(value)
    }

    func test_any_isNotNil_whenArrayContainsEnclosedArray() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value = json.any("0,0")
        // Then
        XCTAssertNotNil(value)
    }

    func test_any_isNotNil_whenArrayContainsEnclosedDict() {
        // When
        let json = try! JSON(data: "[{\"test\": 1}]".data(using: .utf8))
        let value = json.any("0,test")
        // Then
        XCTAssertNotNil(value)
    }

    func test_any_isNotNil_whenPathIsLong() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.any("0,0,0,0,0")
        // Then
        XCTAssertNil(value)
    }

    func test_any_isNotNil_whenPathComponentIsEmpty() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value = json.any("0, ")
        // Then
        XCTAssertNil(value)
    }

    func test_any_isNotNil_whenIndexIncorrect() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.any("1")
        // Then
        XCTAssertNil(value)
    }

    func test_data_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value = json.data("0")
        // Then
        XCTAssertEqual(value?.count, 3)
    }

    func test_data_isNotEmpty_whenDataIsDict() {
        // When
        let json = try! JSON(data: "{\"test\": [1]}".data(using: .utf8))
        let value = json.data("test")
        // Then
        XCTAssertEqual(value?.count, 3)
    }
    
    func test_forcedData_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value = json.forcedData("0")
        // Then
        XCTAssertEqual(value.count, 3)
    }
    
    func test_forcedData_isEmpty_whenDataIsDict() {
        // When
        let json = try! JSON(data: "1".data(using: .utf8))
        let value = json.forcedData("test")
        // Then
        XCTAssertEqual(value.count, 0)
    }

    func test_data_isNil_whenDataIsPrimitive() {
        // When
        let json = try! JSON(data: "1".data(using: .utf8))
        let value = json.data("*")
        // Then
        XCTAssertNil(value)
    }

    func test_array_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value: [Any]? = json.array("0")
        // Then
        XCTAssertEqual(value?.count, 1)
    }

    func test_array_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value: [Any]? = json.array("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedArray_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[[1]]".data(using: .utf8))
        let value: [Any] = json.forcedArray("0")
        // Then
        XCTAssertFalse(value.isEmpty)
    }
    
    func test_forcedArray_isEmpty_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value: [Any] = json.forcedArray("0")
        // Then
        XCTAssertTrue(value.isEmpty)
    }

    func test_dict_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[{\"test\": 1}]".data(using: .utf8))
        let value: [String: Any]? = json.dictionary("0")
        // Then
        XCTAssertEqual(value?.count, 1)
    }

    func test_dict_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value: [String: Any]? = json.dictionary("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedDict_isNotEmpty_whenDataIsArray() {
        // When
        let json = try! JSON(data: "[{\"test\": 1}]".data(using: .utf8))
        let value: [String: Any] = json.forcedDictionary("0")
        // Then
        XCTAssertFalse(value.isEmpty)
    }
    
    func test_forcedDict_isEmpty_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value: [String: Any] = json.forcedDictionary("0")
        // Then
        XCTAssertTrue(value.isEmpty)
    }

    func test_bool_isTrue_whenDataIsTrue() {
        // When
        let json = try! JSON(data: "[true]".data(using: .utf8))
        let value = json.bool("0")
        // Then
        XCTAssertTrue(value ?? false)
    }

    func test_bool_isFalse_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.bool("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedBool_isTrue_whenDataIsTrue() {
        // When
        let json = try! JSON(data: "[true]".data(using: .utf8))
        let value = json.forcedBool("0")
        // Then
        XCTAssertTrue(value)
    }
    
    func test_forcedBool_isFalse_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.forcedBool("0")
        // Then
        XCTAssertFalse(value)
    }

    func test_string_isExist_whenDataIsString() {
        // When
        let json = try! JSON(data: "[\"test\"]".data(using: .utf8))
        let value = json.string("0")
        // Then
        XCTAssertEqual(value, "test")
    }

    func test_string_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.string("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedString_isExist_whenDataIsString() {
        // When
        let json = try! JSON(data: "[\"test\"]".data(using: .utf8))
        let value = json.forcedString("0")
        // Then
        XCTAssertEqual(value, "test")
    }
    
    func test_forcedString_isEmpty_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.forcedString("0")
        // Then
        XCTAssertTrue(value.isEmpty)
    }

    func test_int_isExist_whenDataIsInt() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.int("0")
        // Then
        XCTAssertEqual(value, 1)
    }

    func test_int_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.int("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedInt_isExist_whenDataIsInt() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.forcedInt("0")
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_forcedInt_isZero_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.forcedInt("0")
        // Then
        XCTAssertEqual(value, 0)
    }

    func test_float_isExist_whenDataIsFloat() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.float("0")
        // Then
        XCTAssertEqual(value, 1)
    }

    func test_float_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.float("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedFloat_isExist_whenDataIsInt() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.forcedFloat("0")
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_forcedFloat_isZero_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.forcedFloat("0")
        // Then
        XCTAssertEqual(value, 0)
    }

    func test_double_isExist_whenDataIsDouble() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.double("0")
        // Then
        XCTAssertEqual(value, 1)
    }

    func test_double_isNil_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.double("0")
        // Then
        XCTAssertNil(value)
    }
    
    func test_forcedDouble_isExist_whenDataIsInt() {
        // When
        let json = try! JSON(data: "[1]".data(using: .utf8))
        let value = json.forcedDouble("0")
        // Then
        XCTAssertEqual(value, 1)
    }
    
    func test_forcedDouble_isZero_whenDataNotExist() {
        // When
        let json = try! JSON(data: "[]".data(using: .utf8))
        let value = json.forcedDouble("0")
        // Then
        XCTAssertEqual(value, 0)
    }

    func test_int_isExist_whenDataIsRoot() {
        // When
        let json = try! JSON(data: "1".data(using: .utf8))
        let value = json.int("*")
        // Then
        XCTAssertEqual(value, 1)
    }

    func test_any_isNil_whenPathIsEmpty() {
        // When
        let json = try? JSON(data: "".data(using: .utf8))
        let value = json?.any("")
        // Then
        XCTAssertNil(value)
    }
}

