//
//  VKTests.swift
//  VKTests
//
//  Created by Алексей Кудрявцев on 18.04.15.
//  Copyright (c) 2015 Алексей Кудрявцев. All rights reserved.
//

import XCTest
@testable import SwiftyVK


class UI_Tests: XCTestCase {
  
  
  
  
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
}
