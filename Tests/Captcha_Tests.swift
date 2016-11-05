import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Captcha_Tests: XCTestCase {
    
    let delay : Double = 60
    
    
    
    func test_right_answer() {
        let exp = expectation(description: "ready")
        Stubs.apiWith(method: "captcha.force", jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        Stubs.Captcha.success(caller: self)
        
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
        let exp = expectation(description: "ready")
        Stubs.apiWith(method: "captcha.force", jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        Stubs.Captcha.failed(caller: self)
        
        var req = VK.API.custom(method: "captcha.force")
        req.maxAttempts = 2
        
        req.send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                exp.fulfill()
        })
        
        waitForExpectations(timeout: delay) {_ in}
    }
}
