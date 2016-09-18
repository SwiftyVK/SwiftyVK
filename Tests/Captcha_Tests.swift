import XCTest
import OHHTTPStubs
@testable import SwiftyVK



class Captcha_Tests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        XCUIApplication().launch()
    }
    
    
    let delay : Double = 60
    
    
    
    func test_captcha_synchroniously() {
//        let exp = expectation(description: "ready")
//        Stubs.apiWith(jsonFile: "success.users.get", needCaptcha: true)
//        Stubs.Autorization.success()
//        
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let req = VK.API.Users.get()
//            req.asynchronous = false
//            var executed = false
//            
//            req.send(
//                onSuccess: {response in
//                    executed = true
//                    exp.fulfill()
//                },
//                onError: {error in
//                    XCTFail("Request failed")
//                    exp.fulfill()
//            })
//            if executed == false {
//                XCTFail("Request is not synchronious")
//            }
//        }
//        
//        print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
//        
//        waitForExpectations(timeout: delay) {_ in}
    }
    
    
    
    func test_captcha_asynchroniously() {
        let exp = expectation(description: "ready")
        
        let req = VK.API.custom(method: "captcha.force")
        req.asynchronous = true
        
        req.send(
            onSuccess: {response in
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error in request")
                exp.fulfill()
        })
        
        print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
        
        waitForExpectations(timeout: delay) {_ in}
    }
}
