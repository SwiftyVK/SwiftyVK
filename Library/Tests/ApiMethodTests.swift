import Foundation
import XCTest
@testable import SwiftyVK

final class ApiMethodTests: XCTestCase {
    
    func test_name_equalsToMethodName() {
        // When
        let method = APIScope.Users.get(.empty).toRequest().type.apiMethod
        // Then
        XCTAssertEqual(method, "users.get")
    }
    
    func test_apiMethodParameters_isEmpty() {
        // When
        let parameters = APIScope.Users.get(.empty).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_parameters_equalsToMethodParameters() {
        // When
        let parameter = [Parameter.userId: "1"]
        let parameters = APIScope.Users.get(parameter).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?[Parameter.userId.rawValue] ?? "", "1")
    }
    
    func test_callSessionSend_whenMethodSended() {
        // Given
        VKStack.mock()
        var sendCallCount = 0
        
        (VK.sessions.default as? SessionMock)?.onSend = { request in
            sendCallCount += 1
        }
        // When
        APIScope.Users.get(.empty).send()
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
    
    func test_setConfig() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailable.self)
    }
    
    func test_setOnSuccess() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableConfigurable.self)
    }
    
    func test_setOnError() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableConfigurable.self)
    }
    
    func test_setNext() {
        // Given
        let originalMethod = APIScope.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
        
        do {
            let lastRequest = try mutatedMethod.toRequest().next(with: Data())?.next(with: Data())?.next(with: Data())
            // Then
            XCTAssertNotNil(lastRequest)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
