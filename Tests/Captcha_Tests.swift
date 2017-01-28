import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Captcha_Tests: XCTestCase {
    
    let delay : Double = 60
    
    
    
    func test_right_answer() {
        let exp = expectation(description: "ready")
        Stubs.apiWith(method: "captcha.force", jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        Stubs.Captcha.success(caller: XCTestCase())
        
        var req = VK.API.custom(method: "captcha.force")
        req.maxAttempts = 2
        
        req.send(
            onSuccess: {response in
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
        })

        waitForExpectations(timeout: delay) {_ in}
    }
    
    
    
    
    func test_wrong_answer() {
        Stubs.apiWith(method: "captcha.force", jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        
        Stubs.Captcha.failed(caller: XCTestCase())
        
        let exp = expectation(description: "ready")
        var req = VK.API.custom(method: "captcha.force")
        req.maxAttempts = 2
        
        req.send(
            onSuccess: {response in
                exp.fulfill()
                XCTFail("Unexpected response: \(response)")
            },
            onError: {error in
                exp.fulfill()
        })
        
        waitForExpectations(timeout: delay) {_ in}
    }
}
