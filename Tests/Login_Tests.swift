import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Login_Tests: VKTestCase {
    
    
    
    let delay : Double = 60
    
    
    
    func test_manual() {
        expectation(forNotification: "TestVkDidAuthorize", object: nil, handler: nil)
        
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.Autorization.success()
        VK.logOut()
        VK.logIn()
        
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")

        waitForExpectations(timeout: delay) {_ in
            XCTAssertEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    func test_auto_synchroniously() {
        let exp = expectation(description: "ready")
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", needAuth: true)
        Stubs.Autorization.success()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let req = VK.API.Users.get()
            req.asynchronous = false
            var executed = false
            
            req.send(
                onSuccess: {response in
                    executed = true
                    exp.fulfill()
                },
                onError: {error in
                    executed = true
                    XCTFail("Unexpected error: \(error)")
            })
            if executed == false {
                XCTFail("Request is not synchronious")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: delay) {_ in
            XCTAssertEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    func test_auto_asynchroniously() {
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", needAuth: true)
        Stubs.Autorization.success()
        let exp = expectation(description: "ready")
        
        VK.API.Users.get().send(
            onSuccess: {response in
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
        })
        
        waitForExpectations(timeout: delay) {_ in
            XCTAssertEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_auto_repeatedly() {
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", needAuth: true)
        Stubs.Autorization.success()
        let exp = expectation(description: "ready")
        var executed = 0
        
        for n in 1...3 {
            VK.API.Users.get().send(
                onSuccess: {response in
                    executed += 1
                    executed == 1 ? VK.logOut() : ()
                    executed >= 3 ? exp.fulfill() : ()
                },
                onError: {error in
                    XCTFail("\(n) call has unexpected error: \(error)")
                    exp.fulfill()
                }
            )
        }
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_auto_off() {
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.defaults.catchErrors = false
        XCTAssertFalse(VK.defaults.catchErrors, "VK should not catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", maxCalls: VK.defaults.maxAttempts, needAuth: true)
        Stubs.Autorization.success()
        let exp = expectation(description: "ready")
        
        VK.API.Users.get().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error.domain, "APIError")
                XCTAssertEqual(error.code, 5, "Unexpected error code")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_auto_denied() {
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", maxCalls: VK.defaults.maxAttempts, needAuth: true)
        Stubs.Autorization.denied()
        let exp = expectation(description: "ready")
        
        VK.API.Users.get().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error.domain, "SwiftyVKDomain")
                XCTAssertEqual(error.code, 2, "Unexpected error code")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
    
    
    
    
    func test_auto_failed() {
        VK.logOut()
        XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        VK.defaults.catchErrors = true
        XCTAssertTrue(VK.defaults.catchErrors, "VK should catch errors")
        Stubs.apiWith(jsonFile: "success.users.get", maxCalls: VK.defaults.maxAttempts, needAuth: true)
        Stubs.Autorization.failed()
        let exp = expectation(description: "ready")
        
        VK.API.Users.get().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error.domain, "SwiftyVKDomain")
                XCTAssertEqual(error.code, 2, "Unexpected error code")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: delay) {error in
            XCTAssertNotEqual(VK.state, VK.States.authorized, "Unexpected VK.state")
        }
    }
}
