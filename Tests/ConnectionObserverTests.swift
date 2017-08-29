import Foundation
import XCTest
@testable import SwiftyVK

class ConnectionObserverTests: XCTestCase {

    
    func test_registerAllObservers() {
        // Given
        var names = [Notification.Name?]()
        let context = makeContext()
        
        context.center.onAddObserver = { name in
            names.append(name)
        }
        // When
        context.observer.setUp(onConnect: {}, onDisconnect: {})
        // Then
        XCTAssertEqual(names[0], Notifications.active)
        XCTAssertEqual(names[1], Notifications.inactive)
        XCTAssertEqual(names[2], Notifications.reachability)
    }
    
    func test_callOnConnect_whenAppResignActive() {
        // Given
        var onConnectCallCount = 0
        var onDisconnectCallCount = 0
        let context = makeContext()
        
        context.observer.setUp(
            onConnect: {
                onConnectCallCount += 1
            },
            onDisconnect: {
                onDisconnectCallCount += 1
            }
        )
        // When
        context.center.blocks[Notifications.active]?(Notification(name: Notifications.active))
        context.center.blocks[Notifications.inactive]?(Notification(name: Notifications.inactive))
        context.center.blocks[Notifications.inactive]?(Notification(name: Notifications.inactive))
        // Then
        XCTAssertEqual(onConnectCallCount, 0)
        XCTAssertEqual(onDisconnectCallCount, 1)
    }
    
    func test_callOnDisonnect_whenAppBecomeActive() {
        // Given
        var onConnectCallCount = 0
        var onDisconnectCallCount = 0
        let context = makeContext()
        
        context.observer.setUp(
            onConnect: {
                onConnectCallCount += 1
            },
            onDisconnect: {
                onDisconnectCallCount += 1
            }
        )
        // When
        context.center.blocks[Notifications.inactive]?(Notification(name: Notifications.inactive))
        context.center.blocks[Notifications.active]?(Notification(name: Notifications.active))
        context.center.blocks[Notifications.active]?(Notification(name: Notifications.active))
        // Then
        XCTAssertEqual(onConnectCallCount, 1)
        XCTAssertEqual(onDisconnectCallCount, 1)
    }
    
    func test_callOnConnect_whenNetworkReachable() {
        // Given
        var onConnectCallCount = 0
        var onDisconnectCallCount = 0
        let context = makeContext()
        
        context.observer.setUp(
            onConnect: {
                onConnectCallCount += 1
            },
            onDisconnect: {
                onDisconnectCallCount += 1
            }
        )
        // When
        context.reachability.isReachable = true
        context.center.blocks[Notifications.reachability]?(Notification(name: Notifications.reachability))
        // Then
        XCTAssertEqual(onConnectCallCount, 1)
        XCTAssertEqual(onDisconnectCallCount, 0)
    }
    
    func test_callOnDisconnect_whenNetworkUnreachable() {
        // Given
        var onConnectCallCount = 0
        var onDisconnectCallCount = 0
        let context = makeContext()
        
        context.observer.setUp(
            onConnect: {
                onConnectCallCount += 1
            },
            onDisconnect: {
                onDisconnectCallCount += 1
            }
        )
        // When
        context.center.blocks[Notifications.inactive]?(Notification(name: Notifications.inactive))
        context.reachability.isReachable = false
        context.center.blocks[Notifications.reachability]?(Notification(name: Notifications.reachability))
        // Then
        XCTAssertEqual(onConnectCallCount, 0)
        XCTAssertEqual(onDisconnectCallCount, 1)
    }
    
    func test_notCallOnDisconnect_whenNetworkUnreachableAndAppIsInactive() {
        // Given
        var onConnectCallCount = 0
        var onDisconnectCallCount = 0
        let context = makeContext()
        
        context.observer.setUp(
            onConnect: {
                onConnectCallCount += 1
        },
            onDisconnect: {
                onDisconnectCallCount += 1
        }
        )
        // When
        context.reachability.isReachable = false
        context.center.blocks[Notifications.reachability]?(Notification(name: Notifications.reachability))
        // Then
        XCTAssertEqual(onConnectCallCount, 0)
        XCTAssertEqual(onDisconnectCallCount, 1)
    }
}

private func makeContext() -> (observer: ConnectionObserverImpl, center: VKNotificationCenterMock, reachability: VKReachabilityMock) {
    let center = VKNotificationCenterMock()
    let reachability = VKReachabilityMock()
    
    let observer = ConnectionObserverImpl(
        appStateCenter: center,
        reachabilityCenter: center,
        reachability: reachability,
        activeNotificationName: Notifications.active,
        inactiveNotificationName: Notifications.inactive,
        reachabilityNotificationName: Notifications.reachability
    )
    
    return (observer, center, reachability)
}

struct Notifications {
    static let active = Notification.Name("active")
    static let inactive = Notification.Name("inactive")
    static let reachability = Notification.Name("reachability")

}
