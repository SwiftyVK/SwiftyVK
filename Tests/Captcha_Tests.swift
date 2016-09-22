import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Captcha_Tests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
    }
    
    
    let delay : Double = 60
    
    
    
    func test_synchroniously() {
        let exp = expectation(description: "ready")
        Stubs.apiWith(jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        Stubs.Captcha.success(caller: self)
        
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
                    XCTFail("Unexpected error: \(error)")
                    exp.fulfill()
            })
            if executed == false {
                XCTFail("Request is not synchronious")
            }
        }
        
        waitForExpectations(timeout: delay) {_ in}
    }
    
    
    
    func test_asynchroniously() {
        let exp = expectation(description: "ready")
        Stubs.apiWith(jsonFile: "success.users.get", needCaptcha: true)
        Stubs.Autorization.success()
        Stubs.Captcha.success(caller: self)
        
        let req = VK.API.Users.get()
        req.asynchronous = true
        
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
    
    
    
    
//    func test_wrong_answer() {
//        let exp = expectation(description: "ready")
//        Stubs.apiWith(jsonFile: "success.users.get", needCaptcha: true)
//        Stubs.Autorization.success()
//        Stubs.Captcha.failed(caller: self)
//        
//        let req = VK.API.Users.get()
//        req.asynchronous = true
//        req.maxAttempts = 1
//        
//        req.send(
//            onSuccess: {response in
//                XCTFail("Unexpected response: \(response)")
//                exp.fulfill()
//            },
//            onError: {error in
//                exp.fulfill()
//        })
//        
//        waitForExpectations(timeout: delay) {_ in}
//    }
}
