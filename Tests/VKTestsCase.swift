import XCTest
@testable import SwiftyVK


class VKTestCase : XCTestCase {


  
  override func setUp() {
//    VK.defaults.allowLogToConsole = true
    VK.Log.purge()
    super.setUp()
  }

  
  
  override func tearDown() {
//    printSync(VK.Log.get())
    super.tearDown()
  }
  
  
  
  func getResults(dict: NSMutableDictionary) -> (all: [AnyObject], unused: [AnyObject], success: [AnyObject], error: [AnyObject], statistic: String) {
    let all = dict.map({(index, value) in index})
    let unused = dict.filter({$1 as? String == "~"}).map({(index, value) in index})
    let success = dict.filter({$1 as? String == "+"}).map({(index, value) in index})
    let error = dict.filter({$1 as? String == "-"}).map({(index, value) in index})
    var statistic = "+: \(success.count), -: \(error.count) ~: \(unused.count) of \(all.count)"
    
    if error.count > 0 {
      statistic += "\n-: \(error)"
    }
    if unused.count > 0 {
      statistic += "\n-: \(unused)"
    }
    
    return (all, unused, success, error, statistic)
  }
}
