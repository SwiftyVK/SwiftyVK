import XCTest
@testable import SwiftyVK


class Misc_Tests: VKTestCase {
  
  
  
  func test_language() {
    print("\n\nLocales \(NSLocale.preferredLanguages())")
    
    if let lang = VK.defaults.language {
      print("SwiftyVK language is \"" + lang + "\"\n")
    }
    else {
      XCTFail("Language not set")
    }
  }
  
  
  func test_performance() {
    VK.defaults.maxRequestsPerSec = 3
    //VK.defaults.logOptions = [.APIBlock, .request]
    
    self.measureBlock() {
      let readyExpectation = self.expectationWithDescription("ready")
      var reqCount = 0
      
      for n in 1...VK.defaults.maxRequestsPerSec {
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.isAsynchronous = true
        printSync("<- sending \(n) request")
        req.send(
          {response in
            printSync("-> success \(n) request")
            reqCount++
            reqCount == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
          },
          {error in
            printSync(">< error \(n) request")
            reqCount++
            reqCount == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        })
      }
      
      self.waitForExpectationsWithTimeout(30, handler: { error in
        printSync("")
        XCTAssertNil(error, "Timeout error")
      })
    }
  }
  
  
  
  func test_quick_sending() {
    VK.defaults.maxRequestsPerSec = 100
    
    let readyExpectation = self.expectationWithDescription("ready")
    var reqCount = 0
    let dict = NSMutableDictionary()
    
    for n in 1...VK.defaults.maxRequestsPerSec {
      autoreleasepool {
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        dict[req.id] = "FAIL"
        req.isAsynchronous = true
        printSync("<- sending \(n) request")
        req.send(
          {response in
            dict[req.id] = "Success"
            reqCount++
            printSync("-> success \(reqCount) request of \(VK.defaults.maxRequestsPerSec)")
            reqCount >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
          },
          {error in
            dict[req.id] = "Error"
            reqCount++
            printSync(">< error \(reqCount) request of \(VK.defaults.maxRequestsPerSec)")
            reqCount >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        })
      }
    }
    
    
    self.waitForExpectationsWithTimeout(60, handler: { error in
      printSync("Success: \(dict.filter({$1 as? String == "Success"}).count)")
      printSync("Error: \(dict.filter({$1 as? String == "Error"}).count)")
      printSync("Fail: \(dict.filter({$1 as? String == "FAIL"}).count)")
      printSync(dict)
      XCTAssertNil(error, "Timeout error")
    })
  }
}
