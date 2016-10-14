import XCTest
@testable import SwiftyVK
import OHHTTPStubs


class VKTestCase : XCTestCase {
    let reqTimeout = 5.0
    
    
    
    override func setUp() {
        super.setUp()
        VK.config.logToConsole = true
//        VK.Log.purge()
        _ = ReqClock()
        
        if VK.config.logToConsole {
            printSync("!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!\n")
        }
    }
    
    
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
        
        if VK.config.logToConsole {
            printSync("\n!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!~~~~~~~~~~!")
        }
        
    }
    
    
    
    func getResults(_ dict: NSMutableDictionary) -> (all: [Any], unused: [Any], success: [Any], error: [Any], statistic: String) {
        let all = dict.map({(index, value) in index})
        let unused  = dict.filter({$1 as? String == "~"}).map({(index, value) in index})
        let success = dict.filter({$1 as? String == "+"}).map({(index, value) in index})
        let error   = dict.filter({$1 as? String == "-"}).map({(index, value) in index})
        var statistic = "+: \(success.count), -: \(error.count) ~: \(unused.count) of \(all.count)"
        
        if error.count > 0 {
            statistic += "\n-: \(error)"
        }
        if unused.count > 0 {
            statistic += "\n~: \(unused)"
        }
        
        return (all, unused, success, error, statistic)
    }
}
