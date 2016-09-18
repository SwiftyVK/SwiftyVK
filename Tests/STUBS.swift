//
//  STUBS.swift
//  Example
//
//  Created by Алексей Кудрявцев on 15.09.16.
//
//

import Foundation
import XCTest
import OHHTTPStubs



class ReqClock : NSObject {
    fileprivate static var count = 0
    
    override init() {
        super.init()
        let timer = Timer(timeInterval: 0.35, target: ReqClock.self, selector: #selector(ReqClock.cycle), userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @objc private static func cycle() {
        ReqClock.count = max(0, ReqClock.count-1)
    }
}



#if os(iOS)
    private let captchaData = UIImagePNGRepresentation(#imageLiteral(resourceName: "captcha.jpg"))!
#endif
#if os(OSX)
    private let captchaData = #imageLiteral(resourceName: "captcha.jpg").tiffRepresentation!
#endif



struct Stubs {
    static func apiWith(
        method: String = "users.get",
        jsonFile: String,
        maxCalls: Int = Int.max,
        shouldFails: Int = 0,
        delay: Double? = nil,
        needAuth: Bool = false,
        needCaptcha: Bool = false
        ) {
        
        guard let filePath = Bundle(for:VKTestCase.self).path(forResource: jsonFile, ofType: "json") else {
            XCTFail("Can't find the \(jsonFile).json file")
            return
        }
        
        guard let authPath = Bundle(for:VKTestCase.self).path(forResource: "error.need.authorazation", ofType: "json") else {
            XCTFail("Can't find the error.need.authorazation.json file")
            return
        }
        
        guard let captchaPath = Bundle(for:VKTestCase.self).path(forResource: "error.need.captcha", ofType: "json") else {
            XCTFail("Can't find the error.need.captcha.json file")
            return
        }
        
        var callCount = 0
        let authBlock = needAuth
            ? (containsQueryParams(["access_token" : "1234567890"]))
            : {_ in true}
        
        let capthchaBlock = needCaptcha
            ? (containsQueryParams(["captcha_sid" : "1234567890"]))
            : {_ in true}
        
        if needAuth {
            _ = stub(condition: isScheme("https") && isHost("api.vk.com") && pathStartsWith("/method/"+method) && !authBlock) {_ in
                return Simulates.success(filePath: authPath, delay: nil)
            }
        }
        
        if needCaptcha {
            _ = stub(condition: isScheme("https") && isHost("api.vk.com") && pathStartsWith("/method/"+method) && !capthchaBlock) {_ in
                return Simulates.success(filePath: captchaPath, delay: nil)
            }
            
            _ = stub(condition: isScheme("https") && isHost("api.vk.com") && pathStartsWith("/captcha.php")) {_ in
                return OHHTTPStubsResponse(data: captchaData, statusCode: 200, headers: nil)
            }
        }
        
        _ = stub(condition: isScheme("https") && isHost("api.vk.com") && pathStartsWith("/method/"+method) && authBlock && capthchaBlock) { _ in
            callCount += 1
            ReqClock.count += 1
            
            if ReqClock.count > 3 {
                return Simulates.tooManyRequests()
            }
            else if callCount > maxCalls && callCount > shouldFails+1 {
                XCTFail("Too many calls: (\(callCount)), expected: \(maxCalls)")
                return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
            }
            else if callCount > shouldFails {
                return Simulates.success(filePath: filePath, delay: delay)
            }
            else {
                return Simulates.noConnection()
            }
        }
    }
    
    
    
    struct Autorization {
        static func success() {
            authWith(redirect: "https://oauth.vk.com/blank.html#access_token=1234567890&expires_in=0&user_id=0")
        }
        
        
        
        static func denied() {
            authWith(redirect: "https://oauth.vk.com/blank.html#error=access_denied&error_reason=user_denied")
        }
        
        
        
        static func failed() {
            authWith(redirect: "https://oauth.vk.com/blank.html#fail=1")
        }
        
        
        
        private static func authWith(redirect: String) {
            _ = stub(condition: isScheme("https") && isHost("oauth.vk.com") && pathStartsWith("/authorize")) { _ in
                return OHHTTPStubsResponse(data: Data(), statusCode: 301, headers: [
                    "Location" : redirect
                    ])
            }
            
            _ = stub(condition: isScheme("https") && isHost("oauth.vk.com") && pathStartsWith("/blank.html")) { _ in
                return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
            }
        }
    }
    
    
    
    
    private struct Simulates {
        static func success(filePath: String, delay: Double?) -> OHHTTPStubsResponse {
            let response = OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: nil)
            response.responseTime = delay != nil ? delay! : 0.01*Double(arc4random_uniform(100))
            return response
        }
        
        
        
        static func noConnection() -> OHHTTPStubsResponse {
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
        }
        
        
        
        static func tooManyRequests() -> OHHTTPStubsResponse {
            guard let filePath = Bundle(for:VKTestCase.self).path(forResource: "error.too.many.requests", ofType: "json") else {
                XCTFail("Can't find the error.too.many.requests.json file")
                return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
            }
            
            let response = OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: nil)
            return response
        }
    }
}
