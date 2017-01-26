import XCTest
@testable import SwiftyVK


class Sending_Tests: VKTestCase {
    
    func test_get_method() {
        Stubs.apiWith(params: ["user_ids":"1"], httpMethod: .GET, jsonFile: "success.users.get")
        let exp = expectation(description: "ready")
        
        var req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.httpMethod = .GET

        req.send(
            onSuccess: {response in
                XCTAssertEqual(response[0,"id"].int, 1)
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_post_method() {
        Stubs.apiWith(params: ["user_ids":"1"], httpMethod: .POST, jsonFile: "success.users.get")
        let exp = expectation(description: "ready")
        
        var req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.httpMethod = .POST
        
        req.send(
            onSuccess: {response in
                XCTAssertEqual(response[0,"id"].int, 1)
                exp.fulfill()
            },
            onError: {error in
                XCTFail("Unexpected error: \(error)")
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_for_memory_leak() {
        Stubs.apiWith(jsonFile: "success.users.get")
        let exp = expectation(description: "ready")
        
        var strongObject: NSObject? = NSObject()
        weak var weakObject: NSObject? = strongObject
        strongObject = nil
        
        VK.API.Users.get([VK.Arg.userIDs : "a"]).send(
            onSuccess: {_ in
                let _ = strongObject?.description
                exp.fulfill()
            },
            onError: {_ in
                let _ = strongObject?.description
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: reqTimeout) {_ in
            XCTAssertNil(weakObject, "Test object did not released")
        }
    }
    
    
    
    func test_execute_error() {
        Stubs.apiWith(method: "groups.isMember", jsonFile: "error.missing.parameter", maxCalls: VK.config.maxAttempts)
        let exp = expectation(description: "ready")
        
        VK.API.Groups.isMember().send(
            onSuccess: {response in
                XCTFail("Unexpected response: \(response)")
                exp.fulfill()
            },
            onError: {error in
                XCTAssertEqual(error._code, 100)
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_limited_send() {
        Stubs.apiWith(jsonFile: "success.users.get")
        VK.config.useSendLimit = true
        let backup = VK.config.sendLimit
        let needSendCount = Stubs.enabled ? 10 : 100
//        VK.config.sendLimit = needSendCount
        let exp = self.expectation(description: "ready")
        let requests = NSMutableDictionary()
        var executed = 0
        var shouldNextExecuted = 1
        
        for n in 1...needSendCount {
            requests[n] = "~"
            
            VK.API.Users.get([VK.Arg.userIDs : "\(n)"]).send(
                onSuccess: {response in
                    XCTAssertEqual(n, shouldNextExecuted)
                    shouldNextExecuted += 1
                    requests[n] = "+"
                    executed += 1
                    executed >= needSendCount ? exp.fulfill() : ()
                },
                onError: {error in
                    XCTAssertEqual(n, shouldNextExecuted)
                    shouldNextExecuted += 1
                    requests[n] = "-"
                    executed += 1
                    executed >= needSendCount ? exp.fulfill() : ()
            })
        }
        
        self.waitForExpectations(timeout: reqTimeout*20) {_ in
            VK.config.sendLimit = backup
            let results = self.getResults(requests)
            print(results.statistic)
            XCTAssertGreaterThan(max(results.all.count/50, 1), results.error.count, "Too many errors")
            XCTAssertTrue(results.unused.isEmpty, "\(results.unused.count) requests was not send")
        }
    }
    
    
    
    func test_unlimited_send() {
        guard Stubs.enabled else {return}
    
        Stubs.apiWith(method: "users.get", jsonFile: "success.users.get", delay: 10)
        Stubs.apiWith(method: "users.getFollowers", jsonFile: "success.users.get")

        VK.config.useSendLimit = false
        
        var slowRequestIsExecuted = false
        
        let needFastRequestExecutions = 10
        var fastRequestExetutedCount = 0
        
        let exp = self.expectation(description: "ready")
        
        VK.API.Users.get().send(
            onSuccess: {response in
                slowRequestIsExecuted = true
            },
            onError: {error in
                slowRequestIsExecuted = true
            }
        )
        
        for _ in 1...needFastRequestExecutions {
            
            VK.API.Users.getFollowers().send(
                onSuccess: {response in
                    fastRequestExetutedCount += 1
                    fastRequestExetutedCount >= needFastRequestExecutions ? exp.fulfill() : ()
                },
                onError: {error in
                    fastRequestExetutedCount += 1
                    fastRequestExetutedCount >= needFastRequestExecutions ? exp.fulfill() : ()
                }
            )
        }
        
        self.waitForExpectations(timeout: reqTimeout*20) {_ in
            VK.config.useSendLimit = true
            XCTAssertFalse(slowRequestIsExecuted)
        }
    }
    
    
    
    func test_performance() {
        measure() {
            Stubs.apiWith(jsonFile: "success.users.get")
            let exp = self.expectation(description: "ready")
            var executed = 0
            
            for n in 1...5 {
                let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
                req.send(
                    onSuccess: {response in
                        executed += 1
                        executed == VK.config.sendLimit ? exp.fulfill() : ()
                    },
                    onError: {error in
                        executed += 1
                        executed == VK.config.sendLimit ? exp.fulfill() : ()
                })
            }
            
            self.waitForExpectations(timeout: self.reqTimeout*Double(VK.config.sendLimit)) {_ in}
        }
    }
}
