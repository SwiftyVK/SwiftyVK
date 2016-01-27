import XCTest
@testable import SwiftyVK


class UI_Tests: VKTestCase {
  
  
  
  
  func test_logout_and_login_again() {
    let readyExpectation = expectationWithDescription("ready")
    VK.logOut()
    
    VK.API.Messages.getDialogs(nil).send(
      {response in
        readyExpectation.fulfill()
      },
      {error in
        XCTFail("Autorization failed")
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than 60 seconds.")
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_send_asynchronious_captcha_request() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.custom(method: "captcha.force", parameters: nil)
    req.isAsynchronous = true
    
    req.send(
      {response in
        readyExpectation.fulfill()
      },
      {error in
        readyExpectation.fulfill()
    })
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than 60 seconds.")
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_send_synchronious_captcha_request() {
    let readyExpectation = expectationWithDescription("ready")
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let req = VK.API.custom(method: "captcha.force", parameters: nil)
      req.isAsynchronous = false
      var isDone = false
      
      req.send(
        {response in
          isDone = true
          readyExpectation.fulfill()
        },
        {error in
          isDone = true
          readyExpectation.fulfill()
      })
      if isDone == false {
        XCTFail("Request is not synchronious")
      }
    }
    
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than 60 seconds.")
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_logout_and_sending() {
    let readyExpectation = expectationWithDescription("ready")
    var reqCount = 0
    
    for n in 1...3 {
      printSync("Sending \(n) request")
      VK.API.Messages.getDialogs(nil).send(
        {response in
          printSync("success \(n) request")
          reqCount++
          reqCount >= 3 ? readyExpectation.fulfill() : ()
        },
        {error in
          printSync("error \(n) request")
          reqCount++
          reqCount >= 3 ? readyExpectation.fulfill() : ()
        }
      )
    }
    
    VK.logOut()
    print(">>> USER ACTION IS REQUIRED! Please switch to the test application and autorize. This test will wait no longer than 60 seconds.")
    
    waitForExpectationsWithTimeout(60, handler: { error in
      
      if error == nil {
        let req = VK.API.Messages.getDialogs(nil)
        req.catchErrors = false
        req.isAsynchronous = false
        req.send(
          {response in},
          {error in
            XCTFail("Autorization failed")
          }
        )
      }
      
      XCTAssertNil(error, "Timeout error")
    })
  }
}
