import XCTest
@testable import SwiftyVK


class Requests_Tests: VKTestCase {

  
  
  func test_send_few_asynchronious_requests() {
    let readyExpectation = expectationWithDescription("ready")
    var reqCount = 0
    printSync(nextRequestId)
    let dict = NSMutableDictionary()
    
    for n in 1...10 {
      let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
      req.isAsynchronous = true
      dict[req.id] = "FAIL"
      printSync("Sending \(n) request")
      req.send(
        {response in
          dict[req.id] = "Success"
          printSync("success \(n) request")
          reqCount++
          reqCount >= 10 ? readyExpectation.fulfill() : ()
        },
        {error in
          dict[req.id] = "Error"
          XCTFail("Error \(n) request \(error)")
      })
    }
    
    waitForExpectationsWithTimeout(30, handler: { error in
      printSync(dict)
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_send_few_synchronious_requests() {
    //VK.defaults.logOptions = [.thread]
    
    let readyExpectation = expectationWithDescription("ready")
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      for n in 1...10 {
        var reqIsDone = false
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.isAsynchronous = false
        printSync("Sending \(n) request")
        
        req.send(
          {response in
            reqIsDone = true
            printSync("success \(n) request")
          },
          {error in
            reqIsDone = true
            XCTFail("Error \(n) request \(error)")
        })
        
        reqIsDone == false ? XCTFail("Request \(n) is not synchronious") : ()
        n >= 10 ? readyExpectation.fulfill() : ()
      }
    }
    
    waitForExpectationsWithTimeout(30, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_send_few_random_requests() {
    let readyExpectation = expectationWithDescription("ready")
    var reqCount = 0
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      for n in 1...10 {
        let isAsynchronous = !(n % 3 == 0)
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.isAsynchronous = isAsynchronous
        var isDone = false
        
        printSync("Sending \(n) request")
        
        req.send(
          {response in
            reqCount++
            isDone = true
            printSync("success \(n) request")
            reqCount >= 10 ? readyExpectation.fulfill() : ()
          },
          {error in
            XCTFail("Error \(n) request \(error)")
        })
        
        if isAsynchronous == false && isDone == false {
          XCTFail("Request \(n) is not synchronious")
        }
      }
    }
    
    
    waitForExpectationsWithTimeout(30, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  
  func test_offline_send() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
    req.maxAttempts = 0
    req.send(
      {response in
        printSync("Suсcess")
        readyExpectation.fulfill()
      },
      {error in
        XCTFail("Error \(error)")
    })
    
    
    waitForExpectationsWithTimeout(30, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
}
