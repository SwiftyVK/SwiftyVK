import Foundation
import XCTest
@testable import SwiftyVK

class CustomMethodTests: XCTestCase {
    
    func test_customName_equalsToMethodName() {
        // When
        let method = VK.Api.Custom.method(name: "test").request().rawRequest.apiMethod
        // Then
        XCTAssertEqual(method, "test")
    }
    
    func test_remoteName_equalsToMethodName() {
        // When
        let method = VK.Api.Custom.remote(method: "test").request().rawRequest.apiMethod
        // Then
        XCTAssertEqual(method, "execute.test")
    }
    
    func test_executeName_equalsToExecute() {
        // When
        let method = VK.Api.Custom.execute(code: "").rawRequest.apiMethod
        // Then
        XCTAssertEqual(method, "execute")
    }
    
    func test_executeCode_equalsToParameters() {
        // When
        let parameters = VK.Api.Custom.execute(code: "code").rawRequest.parameters
        // Then
        XCTAssertEqual(parameters?[VK.Arg.code] ?? "", "code")
    }
    
    func test_parameters_isEmpty() {
        // When
        let parameters = VK.Api.Custom.method(name: "test", parameters: .empty).request().rawRequest.parameters
        // Then
        XCTAssertEqual(parameters?.isEmpty, true)
    }
    
    func test_parameters_equalsToMethodParameters() {
        // When
        let parameter = [VK.Arg.userId: "1"]
        let parameters = VK.Api.Custom.method(name: "test", parameters: parameter).request().rawRequest.parameters
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
        VK.Api.Custom.method(name: "test").send(with: .empty)
        // Then
        XCTAssertEqual(sendCallCount, 1)
    }
}

