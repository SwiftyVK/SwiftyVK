import XCTest
@testable import SwiftyVK
import UIKit

final class AppLifecycleProviderTests: XCTestCase {
    
    func test_notification_didBecomeActive() {
        let object = NSArray()
        let provider = IOSAppLifecycleProvider()
        
        let exp = expectation(description: "")
        
        provider.subscribe(object) {
            if $0 == .active {
            exp.fulfill()
            } else {
                XCTFail("Unexpected state \($0)")
                exp.fulfill()
            }
        }
        
        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: UIApplication.shared
        )
        
        waitForExpectations(timeout: 1)
    }
    
    func test_notification_willResignActive() {
        let object = NSArray()
        let provider = IOSAppLifecycleProvider()
        
        let exp = expectation(description: "")
        
        provider.subscribe(object) {
            if $0 == .inactive {
                exp.fulfill()
            } else {
                XCTFail("Unexpected state \($0)")
                exp.fulfill()
            }
        }
        
        NotificationCenter.default.post(
            name: UIApplication.willResignActiveNotification,
            object: UIApplication.shared
        )
        
        waitForExpectations(timeout: 1)
    }
    
    func test_notification_didEnterBackground() {
        let object = NSArray()
        let provider = IOSAppLifecycleProvider()
        
        let exp = expectation(description: "")
        
        provider.subscribe(object) {
            if $0 == .background {
                exp.fulfill()
            } else {
                XCTFail("Unexpected state \($0)")
                exp.fulfill()
            }
        }
        
        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: UIApplication.shared
        )
        
        waitForExpectations(timeout: 1)
    }
    
    func test_notification_willEnterForeground() {
        let object = NSArray()
        let provider = IOSAppLifecycleProvider()
        
        let exp = expectation(description: "")
        
        provider.subscribe(object) {
            if $0 == .foreground {
                exp.fulfill()
            } else {
                XCTFail("Unexpected state \($0)")
                exp.fulfill()
            }
        }
        
        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared
        )
        
        waitForExpectations(timeout: 1)
    }
    
    func test_unsubscribe() {
        let object = NSArray()
        let provider = IOSAppLifecycleProvider()
        
        let exp = expectation(description: "")
        exp.isInverted = true
        
        provider.subscribe(object) {
            if $0 == .active {
                exp.fulfill()
            } else {
                XCTFail("Unexpected state \($0)")
                exp.fulfill()
            }
        }
        
        provider.unsubscribe(object)
        
        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: UIApplication.shared
        )
        
        waitForExpectations(timeout: 1)
    }
}
