import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Login_Tests: VKTestCase {
    
    
    
    let delay : Double = 60
    
    
    private func prepareForLogin() {
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.config.catchErrors = true
        XCTAssertTrue(VK.config.catchErrors, "VK should catch errors")
        
        Stubs.apiWith(method: "users.isAppUser", jsonFile: "success.users.get", needAuth: true)
    }
    
    
    
    func test_manual_login() {
        prepareForLogin()
        expectation(forNotification: "TestVkDidAuthorize", object: nil, handler: nil)
        
        Stubs.Autorization.success()
        VK.logIn()
        
        waitForExpectations(timeout: delay) {_ in
            XCTAssertEqual(VK.state, .authorized, "Unexpected VK.state")
        }
    }
    
    
    
    func test_auto_login() {
        prepareForLogin()
        Stubs.Autorization.success()
        let exp = expectation(description: "ready")
        
        VK.API.Users.isAppUser().send(
            onSuccess: {response in
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
        })
        
        waitForExpectations(timeout: delay) {_ in
            XCTAssertEqual(VK.state, .authorized, "Unexpected VK.state")
        }
    }
    
    
    
    func test_auto_login_off() {
        prepareForLogin()
        VK.config.catchErrors = false
        Stubs.Autorization.success()
        let exp = expectation(description: "ready")
        
        VK.API.Users.isAppUser().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual((error as? ApiError)?._code, 5, "Unexpected error")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, .authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_user_denied() {
        prepareForLogin()
        Stubs.Autorization.denied()
        let exp = expectation(description: "ready")
        
        VK.API.Users.isAppUser().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error as? AuthError, .deniedFromUser, "Unexpected error")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, .authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_auto_failed() {
        guard Stubs.enabled else {return}
        
        prepareForLogin()
        Stubs.Autorization.failed()
        let exp = expectation(description: "ready")
        
        VK.API.Users.isAppUser().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error as? AuthError, .deniedFromUser, "Unexpected error code")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, .authorized, "Unexpected VK.state")
        }
    }
}
