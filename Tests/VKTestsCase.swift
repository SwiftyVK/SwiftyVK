import XCTest
@testable import SwiftyVK
import OHHTTPStubs


class VKTestCase : XCTestCase {
    
    
    let reqTimeout = 5.0
    private var reqPerSec = 0
    
    
    
    override func setUp() {
        //    VK.defaults.logToConsole = true
        VK.Log.purge()
        super.setUp()
        let timer = Timer(timeInterval: 0.35, target: self, selector: #selector(breakReqPerSec), userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    
    
    
    @objc private func breakReqPerSec() {
        reqPerSec = max(0, reqPerSec-1)
    }
    
    
    
    override func tearDown() {
        //    printSync(VK.Log.get())
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
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
    
    
    
    
    func stubApiWith(
        method: String = "users.get",
        jsonFile: String,
        maxCalls: Int = Int.max,
        shouldFails: Int = 0,
        delay : Double? = nil
        ) {
        
        guard let filePath = Bundle(for:VKTestCase.self).path(forResource: jsonFile, ofType: "json") else {
            XCTFail("Can't find the \(jsonFile).json file")
            return
        }
        
        var callCount = 0
        
        _ = stub(condition: isScheme("https") && isHost("api.vk.com") && pathStartsWith("/method/"+method)) { _ in
            callCount += 1
            self.reqPerSec += 1
            
            if self.reqPerSec > 3 {
               return self.simulateTooManyRequests()
            }
            else if callCount > maxCalls && callCount > shouldFails+1 {
                XCTFail("Too many calls: (\(callCount)), expected: \(maxCalls)")
                return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
            }
            else if callCount > shouldFails {
                return self.simulateSuccessResponse(filePath: filePath, delay: delay)
            }
            else {
                return self.simulateNoConnection()
            }
        }
    }
    
    
    
    func simulateSuccessResponse(filePath: String, delay: Double?) -> OHHTTPStubsResponse {
        let response = OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: nil)
        response.responseTime = delay != nil ? delay! : 0.01*Double(arc4random_uniform(100))
        return response
    }
    
    
    
    func simulateNoConnection() -> OHHTTPStubsResponse {
        let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo:nil)
        return OHHTTPStubsResponse(error:notConnectedError)
    }
    
    
    
    func simulateTooManyRequests() -> OHHTTPStubsResponse {
        guard let filePath = Bundle(for:VKTestCase.self).path(forResource: "error.too.many.requests", ofType: "json") else {
            XCTFail("Can't find the error.too.many.requests.json file")
            return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
        }
        
        let response = OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: nil)
        return response
    }
}
