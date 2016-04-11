import XCTest
@testable import SwiftyVK


class UI_Tests: VKTestCase {
  
  
  
  let delay : Double = 60
  
  
  
  func test_login_synchroniously() {
    let readyExpectation = expectationWithDescription("ready")
    VK.logOut()
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let req = VK.API.Messages.getDialogs()
      req.isAsynchronous = false
      var executed = false
      
      req.send(
        success: {response in
          executed = true
          readyExpectation.fulfill()
        },
        error: {error in
          XCTFail("Unexpected error in request")
      })
      if executed == false {
        XCTFail("Request is not synchronious")
        readyExpectation.fulfill()
      }
    }
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectationsWithTimeout(delay) {_ in
      XCTAssertEqual(VK.state, VK.States.Authorized, "Not autorized")
    }
  }
  
  
  
  func test_login_asynchroniously() {
    let readyExpectation = expectationWithDescription("ready")
    VK.logOut()
    
    VK.API.Messages.getDialogs().send(
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in request")
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectationsWithTimeout(delay) {_ in
      XCTAssertEqual(VK.state, VK.States.Authorized, "Not autorized")
    }
  }
  
  
  
  
  func test_autologin() {
    let readyExpectation = expectationWithDescription("ready")
    var executed = 0
    
    for n in 1...3 {
      VK.API.Messages.getDialogs().send(
        success: {response in
          executed += 1
          executed >= 3 ? readyExpectation.fulfill() : ()
        },
        error: {error in
          XCTFail("Unexpected error in \(n) request: \(error)")
          readyExpectation.fulfill()
        }
      )
    }
    
    VK.logOut()
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectationsWithTimeout(delay) {error in
      XCTAssertEqual(VK.state, VK.States.Authorized, "Not autorized")
    }
  }
  
  
  
  func test_captcha_synchroniously() {
    let readyExpectation = expectationWithDescription("ready")
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let req = VK.API.custom(method: "captcha.force")
      req.isAsynchronous = false
      var executed = false
      
      req.send(
        success: {response in
          executed = true
          readyExpectation.fulfill()
        },
        error: {error in
          XCTFail("Request failed")
          readyExpectation.fulfill()
      })
      if executed == false {
        XCTFail("Request is not synchronious")
      }
    }
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectationsWithTimeout(delay) {_ in}
  }
  
  
  
  func test_captcha_asynchroniously() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.custom(method: "captcha.force")
    req.isAsynchronous = true
    
    req.send(
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in request")
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectationsWithTimeout(delay) {_ in}
  }
}
