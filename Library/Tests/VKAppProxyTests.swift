import XCTest
@testable import SwiftyVK

final class VKAppProxyTests: XCTestCase {
    
    private let appId = "1234567890"
    
    var proxyObjects: (URLOpenerMock, AppLifecycleProviderMock, VKAppProxyImpl) {
        let urlOpener = URLOpenerMock()
        let appLifecycleProvider = AppLifecycleProviderMock()
        
        let vkProxy = VKAppProxyImpl(
            appId: appId,
            urlOpener: urlOpener,
            appLifecycleProvider: appLifecycleProvider
        )
        
        return (urlOpener, appLifecycleProvider, vkProxy)
    }
    
    func test_openUrl_shoudBeSuccess() {
        // Given
        let (urlOpener, appLifecycleProvider, vkProxy) = proxyObjects
        urlOpener.allowCanOpenUrl = true
        urlOpener.allowOpenURL = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            appLifecycleProvider.notify(state: .inactive)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            appLifecycleProvider.notify(state: .active)
        }
        
        // When
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertTrue(result ?? false)
    }
    
    func test_openUrl_shoudBeFail_whenAppDoesntBringToInnactive() {
        // Given
        let (urlOpener, _, vkProxy) = proxyObjects
        urlOpener.allowCanOpenUrl = true
        urlOpener.allowOpenURL = true
        
        // When
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertFalse(result ?? false)
    }
    
    func test_openUrl_shoudBeSuccess_whenAppDoesntBringToActive() {
        // Given
        let (urlOpener, _, vkProxy) = proxyObjects
        urlOpener.allowCanOpenUrl = true
        urlOpener.allowOpenURL = true
        // When
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertFalse(result ?? false)
    }
    
    func test_openUrl_withCantOpenUrl_shouldBeFail() {
        // Given
        let (urlOpener, _, vkProxy) = proxyObjects
        urlOpener.allowCanOpenUrl = false
        urlOpener.allowOpenURL = true
        // When
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertFalse(result ?? true)
    }
    
    func test_recieveUrl_withVKClient_shouldBeSuccess() {
        // Given
        let (_, _, vkProxy) = proxyObjects
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        // When
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withVKHdClient_shouldBeSuccess() {
        // Given
        let (_, _, vkProxy) = proxyObjects
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        // When
        let result = vkProxy.handle(url: url, app: "com.vk.vkhd")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withWrongClient_shouldBeFail() {
        // Given
        let (_, _, vkProxy) = proxyObjects
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        // When
        let result = vkProxy.handle(url: url, app: "com.vk.wrongClient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withWrongScheme_shouldBeFail() {
        // Given
        let (_, _, vkProxy) = proxyObjects
        let url = URL(string: "vkWrongScheme://test/test#access_token=1234567890")!
        // When
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withoutTokenFragment_shouldBeFail() {
        // Given
        let (_, _, vkProxy) = proxyObjects
        let url = URL(string: "vk\(appId)://test/test?access_token=1234567890")!
        // When
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
}
