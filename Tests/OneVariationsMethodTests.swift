import Foundation
import XCTest
@testable import SwiftyVK

class OneVariationsMethodTests: XCTestCase {
    
    func test_setConfig() {
        // Given
        let originalMethod = Methods.Configurable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Basic.self)
    }
    
    func test_setOnSuccess() {
        // Given
        let originalMethod = Methods.Successable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Basic.self)
    }
    
    func test_setOnError() {
        // Given
        let originalMethod = Methods.Failable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Basic.self)
    }
    
    func test_setOnProgress() {
        // Given
        let originalMethod = Methods.Progressable(Request(type: .url("")))
        // When
        let mutatedMethod = originalMethod.onProgress { _,_,_  in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.Basic.self)
    }
}
