import Foundation
import XCTest
@testable import SwiftyVK

final class TwoVariationsMethodTests: XCTestCase {
    
    func test_successableConfigurable_setConfig() {
        // Given
        let originalMethod = Methods.SuccessableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Successable.self)
    }
    
    func test_successableConfigurable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Configurable.self)
    }
    
    func test_successableFailable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableFailable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Failable.self)
    }
    
    func test_successableFailable_setOnError() {
        // Given
        let originalMethod = Methods.SuccessableFailable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Successable.self)
    }
    
    func test_successableProgressable_setOnSuccess() {
        // Given
        let originalMethod = Methods.SuccessableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Progressable.self)
    }
    
    func test_successableProgressable_setOnProgress() {
        // Given
        let originalMethod = Methods.SuccessableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _,_,_  in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Successable.self)
    }
    
    func test_failableConfigurable_setOnError() {
        // Given
        let originalMethod = Methods.FailableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Configurable.self)
    }
    
    func test_failableConfigurable_setConfig() {
        // Given
        let originalMethod = Methods.FailableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Failable.self)
    }
    
    func test_failableProgressable_setOnError() {
        // Given
        let originalMethod = Methods.FailableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Progressable.self)
    }
    
    func test_failableProgressable_setOnProgress() {
        // Given
        let originalMethod = Methods.FailableProgressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _,_,_  in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Failable.self)
    }
    
    func test_progressableConfigurable_setConfig() {
        // Given
        let originalMethod = Methods.ProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Progressable.self)
    }
    
    func test_progressableConfigurable_setOnProgress() {
        // Given
        let originalMethod = Methods.ProgressableConfigurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _,_,_  in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Configurable.self)
    }
}

