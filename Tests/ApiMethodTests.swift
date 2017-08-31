import Foundation
import XCTest
@testable import SwiftyVK

class ApiMethodTests: XCTestCase {
    
    func test_name_equalsToMethodName() {
        // When
        let method = VKAPI.Users.get(.empty).request().rawRequest.apiMethod
        // Then
        XCTAssertEqual(method, "users.get")
    }
    
    func test_apiMethodParameters_isEmpty() {
        // When
        let parameters = VKAPI.Users.get(.empty).request().rawRequest.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_parameters_equalsToMethodParameters() {
        // When
        let parameter = [VK.Arg.userId: "1"]
        let parameters = VKAPI.Users.get(parameter).request().rawRequest.parameters
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
        VKAPI.Users.get(.empty).send(with: .empty)
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
}
