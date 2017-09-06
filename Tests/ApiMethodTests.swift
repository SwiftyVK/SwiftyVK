import Foundation
import XCTest
@testable import SwiftyVK

class ApiMethodTests: XCTestCase {
    
    func test_name_equalsToMethodName() {
        // When
        let method = VKAPI.Users.get(.empty).toRequest().type.apiMethod
        // Then
        XCTAssertEqual(method, "users.get")
    }
    
    func test_apiMethodParameters_isEmpty() {
        // When
        let parameters = VKAPI.Users.get(.empty).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_parameters_equalsToMethodParameters() {
        // When
        let parameter = [VK.Arg.userId: "1"]
        let parameters = VKAPI.Users.get(parameter).toRequest().type.parameters
        // Then
        XCTAssertEqual(parameters?[VK.Arg.userId] ?? "", "1")
    }
    
    func test_callSessionSend_whenMethodSended() {
        // Given
        VKStack.mock()
        var sendCallCount = 0
        
        (VK.sessions?.default as? SessionMock)?.onSend = { request in
            sendCallCount += 1
        }
        // When
        VKAPI.Users.get(.empty).send()
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
    
    func test_setConfig() {
        // Given
        let originalMethod = VKAPI.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.configure(with: .default)
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailableProgressable.self)
    }
    
    func test_setOnSuccess() {
        // Given
        let originalMethod = VKAPI.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onSuccess { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.FailableProgressableConfigurable.self)
    }
    
    func test_setOnError() {
        // Given
        let originalMethod = VKAPI.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onError { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableProgressableConfigurable.self)
    }
    
    func test_setOnProgress() {
        // Given
        let originalMethod = VKAPI.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod.onProgress { _ in }
        // Then
        XCTAssertTrue(type(of: mutatedMethod) == Methods.SuccessableFailableConfigurable.self)
    }
    
    func test_setNext() {
        // Given
        let originalMethod = VKAPI.Users.get(.empty)
        // When
        let mutatedMethod = originalMethod
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
            .chain { _ in Request(type: .url("")).toMethod() }
        
        let lastRequest = mutatedMethod.toRequest().next(with: Data())?.next(with: Data())?.next(with: Data())
        // Then
        XCTAssertNotNil(lastRequest)
    }
}
