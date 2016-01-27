import XCTest
@testable import SwiftyVK


class VKTestCase : XCTestCase {


  
  override func setUp() {
//    VK.defaults.logOptions = [.all, .noDebug]
    super.setUp()
    VK.Log.purge()
    VK.defaults.allowLogToConsole = true
  }

  
  
  override func tearDown() {
    printSync(VK.Log.get())
    super.tearDown()
  }
}
