import XCTest
@testable import SwiftyVK


class Sending_Tests: VKTestCase {
    
    
    
    func test_send_get_method() {
        let readyExpectation = expectation(description: "ready")
        
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.asynchronous = true
        
        req.successBlock = {response in
            if response[0,"id"].int == 1 &&
                response[0,"first_name"].string == "TEST" &&
                response[0,"last_name"].string == "USER" {
                readyExpectation.fulfill()
            }
            else {
                XCTFail("Unexpected response in GET request: \(response)")
            }
        }
        
        req.errorBlock = {error in
            XCTFail("Unexpected error in GET request: \(error)")
            readyExpectation.fulfill()
        }
        
        stubApiWith(jsonFile: "success.users.get")
        req.send()
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_send_post_method() {
        let readyExpectation = expectation(description: "ready")
        
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.asynchronous = true
        
        req.successBlock = {response in
            if response[0,"id"].int == 1 &&
                response[0,"first_name"].string == "TEST" &&
                response[0,"last_name"].string == "USER" {
                readyExpectation.fulfill()
            }
            else {
                XCTFail("Unexpected response in GET request: \(response)")
            }
        }
        
        req.errorBlock = {error in
            XCTFail("Unexpected error in GET request: \(error)")
            readyExpectation.fulfill()
        }
        
        stubApiWith(jsonFile: "success.users.get")
        req.send()
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_waiting_for_connection() {
        let readyExpectation = expectation(description: "ready")
        
        let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
        req.maxAttempts = 0
        req.successBlock = {response in
            if response[0,"id"].int == 1 &&
                response[0,"first_name"].string == "TEST" &&
                response[0,"last_name"].string == "USER" {
                readyExpectation.fulfill()
            }
            else {
                XCTFail("Unexpected response in GET request: \(response)")
            }
        }
        
        req.errorBlock = {error in
            XCTFail("Unexpected error in GET request: \(error)")
            readyExpectation.fulfill()
        }
        
        stubApiWith(jsonFile: "success.users.get", shouldFails: 10)
        req.send()
        waitForExpectations(timeout: reqTimeout*10) {_ in}
    }
    
    
    
    func test_executing_error_block() {
        let readyExpectation = expectation(description: "ready")
        let req = VK.API.Users.get()
        
        req.successBlock = {response in
            XCTFail("Unexpected succes in request: \(response)")
            readyExpectation.fulfill()
        }
        
        req.errorBlock = {error in
            if error.domain == "APIError" && error.code == 100 {
                readyExpectation.fulfill()
            }
            else {
                XCTFail("Unexpected error in request: \(error)")
            }
        }
        
        stubApiWith(jsonFile: "error.missing.parameter", maxCalls: req.maxAttempts)
        req.send()
        waitForExpectations(timeout: reqTimeout) {_ in}
    }
    
    
    
    func test_send_synchroniously() {
        let readyExpectation = expectation(description: "ready")
        stubApiWith(jsonFile: "success.users.get", maxCalls: 10)

        DispatchQueue.global(qos: .background).async {
            for n in 1...10 {
                let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
                req.asynchronous = false
                var executed = false
                
                req.send(
                    onSuccess: {response in
                        executed = true
                    },
                    onError: {error in
                        executed = true
                        XCTFail("Unexpected error in \(n) request: \(error)")
                        readyExpectation.fulfill()
                })
                
                if !executed {XCTFail("Request \(n) is not synchronious")}
                if n == 10 {readyExpectation.fulfill()}
            }
        }
        
        waitForExpectations(timeout: reqTimeout*10) {_ in}
    }
    
    
    
    func test_send_asynchroniously() {
        let readyExpectation = expectation(description: "ready")
        stubApiWith(jsonFile: "success.users.get", maxCalls: 10)
        var exeCount = 0
        
        for n in 1...10 {
            let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
            req.asynchronous = true
            req.send(
                onSuccess: {response in
                    exeCount += 1
                    exeCount >= 10 ? readyExpectation.fulfill() : ()
                },
                onError: {error in
                    XCTFail("Unexpected error in \(n) request: \(error)")
                    readyExpectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: reqTimeout*10) {_ in}
    }
    
    
    
    func test_send_high_randomly() {
        let readyExpectation = self.expectation(description: "ready")
        let backup = VK.defaults.maxRequestsPerSec
        VK.defaults.maxRequestsPerSec = 100
        stubApiWith(jsonFile: "success.users.get")
        let requests = NSMutableDictionary()
        var executed = 0
        
        DispatchQueue.global(qos: .background).async {
            for n in 1...VK.defaults.maxRequestsPerSec {
                let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
                requests[req.id] = "~"
                req.asynchronous = n%3 != 0
                
                req.send(
                    onSuccess: {response in
                        requests[req.id] = "+"
                        executed += 1
                        executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
                    },
                    onError: {error in
                        requests[req.id] = "-"
                        executed += 1
                        executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
                })
            }
        }
        
        self.waitForExpectations(timeout: reqTimeout*20) {_ in
            VK.defaults.maxRequestsPerSec = backup
            let results = self.getResults(requests)
            printSync(results.statistic)
            if results.error.count > results.all.count/50 || !results.unused.isEmpty {
                XCTFail("Too many errors")
            }
        }
    }
    
    
    
    func test_send_performance() {
        stubApiWith(jsonFile: "success.users.get")

        self.measure() {
            let readyExpectation = self.expectation(description: "ready")
            var executed = 0
            
            for n in 1...VK.defaults.maxRequestsPerSec*3 {
                let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
                req.asynchronous = true
                req.send(
                    onSuccess: {response in
                        executed += 1
                        executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
                    },
                    onError: {error in
                        executed += 1
                        executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
                })
            }
            
            self.waitForExpectations(timeout: self.reqTimeout*Double(VK.defaults.maxRequestsPerSec)) {_ in}
        }
    }
}
