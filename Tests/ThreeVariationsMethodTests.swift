import Foundation
import XCTest
@testable import SwiftyVK

class ThreeVariationsMethodTests: XCTestCase {
    
    func test_successableFailableProgressable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableFailableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableProgressable.self)
    }
    
    func test_successableFailableProgressable_setOnError() {
        // Given
        let originalMethod = Methods.SuccessableFailableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableProgressable.self)
    }
    
    func test_successableFailableProgressable_setOnProgress() {
        // Given
        let originalMethod = Methods.SuccessableFailableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailable.self)
    }
    
    func test_successableFailableConfigurable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableFailableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableConfigurable.self)
    }
    
    func test_successableFailableConfigurable_setOnError() {
        // Given
        let originalMethod = Methods.SuccessableFailableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableConfigurable.self)
    }
    
    func test_successableFailableConfigurable_setOnProgress() {
        // Given
        let originalMethod = Methods.SuccessableFailableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailable.self)
    }
    
    func test_successableProgressableConfigurable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.ProgressableConfigurable.self)
    }
    
    func test_successableProgressableConfigurable_setOnProgress() {
        // Given
        let originalMethod = Methods.SuccessableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableConfigurable.self)
    }
    
    func test_successableProgressableConfigurable_setConfig() {
        // Given
        let originalMethod = Methods.SuccessableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableProgressable.self)
    }
    
    func test_failableProgressableConfigurable_setOnError() {
        // Given
        let originalMethod = Methods.FailableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.ProgressableConfigurable.self)
    }
    
    func test_failableProgressableConfigurable_setOnProgress() {
        // Given
        let originalMethod = Methods.FailableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableConfigurable.self)
    }
    
    func test_failableProgressableConfigurable_setConfig() {
        // Given
        let originalMethod = Methods.FailableProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableProgressable.self)
    }
}
