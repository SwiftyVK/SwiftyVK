import Foundation
import XCTest
@testable import SwiftyVK

class MethodTests: BaseTestCase {
    
    func test_apiMethodName_equalsToMethodName() {
        // When
        let method = VK.Api.Users.get(.empty).request().rawRequest.apiMethod
        // Then
        XCTAssertEqual(method, "users.get")
    }
    
    func test_apiMethodParameters_isEmpty() {
        // When
        let parameters = VK.Api.Users.get(.empty).request().rawRequest.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_apiMethodParameters_equalsToMethodParameters() {
        // When
        let parameter = [VK.Arg.userId: "1"]
        let parameters = VK.Api.Users.get(parameter).request().rawRequest.parameters
        // Then
        XCTAssertEqual(parameters?[VK.Arg.userId] ?? "", "1")
    }
    
    func test_callSessionSend_whenMethodSended() {
        // Given
        var sendCallCount = 0
        
        (VK.sessions?.default as? SessionMock)?.onSend = { request in
            sendCallCount += 1
        }
        // When
        VK.Api.Users.get(.empty).send(with: .empty)
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
}

private extension Request.Raw {
    var apiMethod: String? {
        switch self {
        case let .api(method, _):
            return method
        default:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .api(_, parameters):
            return parameters
        default:
            return nil
        }
    }
}
