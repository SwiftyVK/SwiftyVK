import XCTest
@testable import SwiftyVK


class Sending_Tests: VKTestCase {

  
  
  func test_A_get_method() {
    let readyExpectation = expectation(description: "ready")
    
      let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
      req.asynchronous = true
      req.send(
        method: .GET,
        success: {response in
          readyExpectation.fulfill()
        },
        error: {error in
          XCTFail("Unexpected error in GET request: \(error)")
          readyExpectation.fulfill()
      })
    
      waitForExpectations(timeout: reqTimeout) {_ in}
  }
  
  
  
  func test_A_post_method() {
    let readyExpectation = expectation(description: "ready")
    
    let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
    req.asynchronous = true
    req.send(
      method: .POST,
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in GET request: \(error)")
        readyExpectation.fulfill()
    })
    
    waitForExpectations(timeout: reqTimeout) {_ in}
  }
  
  
  
  /**
   To use this test you need:
   Disable internet ->
   Run test ->
   Enable internet.
   */
  func test_A_infinite() {
    let readyExpectation = expectation(description: "ready")
    
    let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
    req.maxAttempts = 0
    req.send(
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in request: \(error)")
        readyExpectation.fulfill()
    })
    
    waitForExpectations(timeout: reqTimeout) {_ in}
  }
  
  
  
  func test_A_errorblock() {
    let readyExpectation = expectation(description: "ready")
    
    let req = VK.API.Messages.getHistory()
    req.send(
      success: {response in
        XCTFail("Unexpected succes in request: \(response)")
        readyExpectation.fulfill()
      },
      error: {error in
        readyExpectation.fulfill()
    })
    
    waitForExpectations(timeout: reqTimeout) {_ in}
  }
  
  
  
  func test_B_synchronious() {
    let readyExpectation = expectation(description: "ready")
    
    DispatchQueue.global(qos: .background).async {
      for n in 1...10 {
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.asynchronous = false
        var executed = false
        
        req.send(
          success: {response in
            executed = true
          },
          error: {error in
            executed = true
            XCTFail("Unexpected error in \(n) request: \(error)")
            readyExpectation.fulfill()
        })
        
        if !executed {XCTFail("Request \(n) is not synchronious")}
        if n >= 10 {readyExpectation.fulfill()}
      }
    }
    
    waitForExpectations(timeout: reqTimeout) {_ in}
  }
  
  
  
  func test_B_asynchronious() {
    let readyExpectation = expectation(description: "ready")
    var exeCount = 0
    
    for n in 1...10 {
      let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
      req.asynchronous = true
      req.send(
        success: {response in
          exeCount += 1
          exeCount >= 10 ? readyExpectation.fulfill() : ()
        },
        error: {error in
          XCTFail("Unexpected error in \(n) request: \(error)")
          readyExpectation.fulfill()
      })
    }
    
    waitForExpectations(timeout: reqTimeout*10) {_ in}
  }
  
  
  
  func test_C_random() {
    let readyExpectation = expectation(description: "ready")
    var exeCount = 0
    
    DispatchQueue.global(qos: .background).async {
      for n in 1...10 {
        let asynchronously = !(n % 3 == 0)
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.asynchronous = asynchronously
        var executed = false
        
        req.send(
          success: {response in
            exeCount += 1
            executed = true
            exeCount >= 10 ? readyExpectation.fulfill() : ()
          },
          error: {error in
            XCTFail("Unexpected error in \(n) request: \(error)")
        })
        
        if !asynchronously && !executed {
          XCTFail("Request \(n) is not synchronious")
          readyExpectation.fulfill()
        }
      }
    }
    
    waitForExpectations(timeout: reqTimeout*10) {_ in}
  }
  
  
  
  func test_C_many() {
    let readyExpectation = self.expectation(description: "ready")
    let backup = VK.defaults.maxRequestsPerSec
    VK.defaults.maxRequestsPerSec = 100
    let requests = NSMutableDictionary()
    var executed = 0
    
    for n in 1...VK.defaults.maxRequestsPerSec {
      let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
      requests[req.id] = "~"
      req.asynchronous = true
      
      req.send(
        success: {response in
          requests[req.id] = "+"
          executed += 1
          executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        },
        error: {error in
          requests[req.id] = "-"
          executed += 1
          executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
      })
    }
    
    self.waitForExpectations(timeout: reqTimeout*10) {_ in
      VK.defaults.maxRequestsPerSec = backup
      let results = self.getResults(requests)
      printSync(results.statistic)
      if results.error.count > results.all.count/50 {
        XCTFail("Too many errors")
      }
    }
  }
  
  
  
  func test_C_performance() {
    self.measure() {
      let readyExpectation = self.expectation(description: "ready")
      var executed = 0
      
      for n in 1...VK.defaults.maxRequestsPerSec {
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.asynchronous = true
        req.send(
          success: {response in
            executed += 1
            executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
          },
          error: {error in
            executed += 1
            executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        })
      }
      
      self.waitForExpectations(timeout: self.reqTimeout*Double(VK.defaults.maxRequestsPerSec)) {_ in}
    }
  }
}
