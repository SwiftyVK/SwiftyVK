import XCTest
@testable import SwiftyVK

final class VKProxyTests: BaseTestCase {
    
    var proxyObjects: (UrlOpenerMock, VkAppProxyImpl) {
        let urlOpener = UrlOpenerMock()
        let vkProxy = VkAppProxyImpl(urlOpener: urlOpener)
        return (urlOpener, vkProxy)
    }
    
    func test_openUrl_shoudBeSussess() {
        // Given
        let (urlOpener, vkProxy) = proxyObjects
        // When
        urlOpener.allowCanOpenUrl = true
        urlOpener.allowOpenURL = true
        let result = try! vkProxy.authorizeWith(query: "test")
        // Then
        XCTAssertTrue(result)
    }
    
    func test_openUrl_withCantOpenUrl_shoudBeFail() {
        // Given
        let (urlOpener, vkProxy) = proxyObjects
        // When
        urlOpener.allowCanOpenUrl = false
        urlOpener.allowOpenURL = true
        let result = try! vkProxy.authorizeWith(query: "test")
        // Then
        XCTAssertFalse(result)
    }
    
    func test_recieveUrl_withVkClient_shouldBeSuccess() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(VK.appId!)://test/test#access_token=1234567890")!
        let result = vkProxy.recieveFrom(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withVkHdClient_shouldBeSuccess() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(VK.appId!)://test/test#access_token=1234567890")!
        let result = vkProxy.recieveFrom(url: url, app: "com.vk.vkhd")
        // Then
        XCTAssertEqual(result, "access_token=1234567890")
    }
    
    func test_recieveUrl_withWrongClient_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(VK.appId!)://test/test#access_token=1234567890")!
        let result = vkProxy.recieveFrom(url: url, app: "com.vk.wrongClient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withWrongScheme_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vkWrongScheme://test/test#access_token=1234567890")!
        let result = vkProxy.recieveFrom(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
    
    func test_recieveUrl_withoutTokenFragment_shouldBeFail() {
        // Given
        let (_, vkProxy) = proxyObjects
        // When
        let url = URL(string: "vk\(VK.appId!)://test/test?access_token=1234567890")!
        let result = vkProxy.recieveFrom(url: url, app: "com.vk.vkclient")
        // Then
        XCTAssertNil(result)
    }
}
