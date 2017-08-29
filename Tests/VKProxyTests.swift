import XCTest
@testable import SwiftyVK

final class VKProxyTests: XCTestCase {
    
    private let appId = "1234567890"
    
    var proxyObjects: (UrlOpenerMock, VKAppProxyImpl) {
        let urlOpener = UrlOpenerMock()
        let vkProxy = VKAppProxyImpl(appId: appId, urlOpener: urlOpener)
        return (urlOpener, vkProxy)
    }
    
    func test_openUrl_shoudBeSuccess() {
        // Given
        let (urlOpener, vkProxy) = proxyObjects
        // When
        urlOpener.allowCanOpenUrl = true
        urlOpener.allowOpenURL = true
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertTrue(result ?? false)
    }
    
    func test_openUrl_withCantOpenUrl_shouldBeFail() {
        // Given
        let (urlOpener, vkProxy) = proxyObjects
        // When
        urlOpener.allowCanOpenUrl = false
        urlOpener.allowOpenURL = true
        let result = try? vkProxy.send(query: "test")
        // Then
        XCTAssertFalse(result ?? false)
    }
    
    func test_recieveUrl_withVKClient_shouldBeSuccess() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withVKHdClient_shouldBeSuccess() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        let result = vkProxy.handle(url: url, app: "com.vk.vkhd")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withWrongClient_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(appId)://test/test#access_token=1234567890")!
        let result = vkProxy.handle(url: url, app: "com.vk.wrongClient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withWrongScheme_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vkWrongScheme://test/test#access_token=1234567890")!
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withoutTokenFragment_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(appId)://test/test?access_token=1234567890")!
        let result = vkProxy.handle(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
}
