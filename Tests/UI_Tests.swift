import XCTest
@testable import SwiftyVK



class UI_Tests: VKTestCase {
  
  
  
  let delay : Double = 60
  
  
  
  func test_login_synchroniously() {
    let readyExpectation = expectation(description: "ready")
    VK.logOut()
    
    DispatchQueue.global(qos: .background).async {
      let req = VK.API.Messages.getDialogs()
      req.asynchronous = false
      var executed = false
      
      req.send(
        onSuccess: {response in
          executed = true
          readyExpectation.fulfill()
        },
        onError: {error in
          XCTFail("Unexpected error in request")
      })
      if executed == false {
        XCTFail("Request is not synchronious")
        readyExpectation.fulfill()
      }
    }
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectations(timeout: delay) {_ in
      XCTAssertEqual(VK.state, VK.States.authorized, "Not authorized")
    }
  }
  
  
  
  func test_login_asynchroniously() {
    let readyExpectation = expectation(description: "ready")
    VK.logOut()
    
    VK.API.Messages.getDialogs().send(
      onSuccess: {response in
        readyExpectation.fulfill()
      },
      onError: {error in
        XCTFail("Unexpected error in request")
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectations(timeout: delay) {_ in
      XCTAssertEqual(VK.state, VK.States.authorized, "Not authorized")
    }
  }
  
  
  
  
  func test_autologin() {
    let readyExpectation = expectation(description: "ready")
    var executed = 0
    
    for n in 1...3 {
      VK.API.Messages.getDialogs().send(
        onSuccess: {response in
          executed += 1
          executed >= 3 ? readyExpectation.fulfill() : ()
        },
        onError: {error in
          XCTFail("Unexpected error in \(n) request: \(error)")
          readyExpectation.fulfill()
        }
      )
    }
    
    VK.logOut()
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectations(timeout: delay) {error in
      XCTAssertEqual(VK.state, VK.States.authorized, "Not authorized")
    }
  }
  
  
  
  func test_captcha_synchroniously() {
    let readyExpectation = expectation(description: "ready")
    
    DispatchQueue.global(qos: .background).async {
      let req = VK.API.custom(method: "captcha.force")
      req.asynchronous = false
      var executed = false
      
      req.send(
        onSuccess: {response in
          executed = true
          readyExpectation.fulfill()
        },
        onError: {error in
          XCTFail("Request failed")
          readyExpectation.fulfill()
      })
      if executed == false {
        XCTFail("Request is not synchronious")
      }
    }
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectations(timeout: delay) {_ in}
  }
  
  
  
  func test_captcha_asynchroniously() {
    let readyExpectation = expectation(description: "ready")
    
    let req = VK.API.custom(method: "captcha.force")
    req.asynchronous = true
    
    req.send(
      onSuccess: {response in
        readyExpectation.fulfill()
      },
      onError: {error in
        XCTFail("Unexpected error in request")
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and authorize. This test will wait no longer than \(delay) seconds.")
    
    waitForExpectations(timeout: delay) {_ in}
  }
}
