import XCTest
@testable import SwiftyVK

final class WebPresenterTests: BaseTestCase {
    
    var objects: (WebPresenter & WebHandler, WebControllerMock) {
        let controller = WebControllerMock()
        let presenter = WebPresenterImpl(controller: controller)
        return (presenter, controller)
    }
    
    func test_load_whenTokenRecieved() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        let result = try! presenter.presentWith(url: URL(string: "http://vk.com#access_token=test")!)
        // Then
        XCTAssertEqual(result, "access_token=test")
    }
    
    func test_load_whenAccessDenied() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com#access_denied")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .deniedFromUser)
        }
    }
    
    func test_load_whenFlowCancelled() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com#cancel=1")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .deniedFromUser)
        }
    }
    
    func test_load_whenFlowFailed() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com#fail=1")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .failedAuthorization)
        }
    }
    
    func test_load_whenValidationSuccess() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        let result = try! presenter.presentWith(url: URL(string: "http://vk.com#success=1")!)
        // Then
        XCTAssertEqual(result, "success=1")
    }
    
    func test_load_withWrongUrl() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com#")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .wrongAuthUrl)
        }
    }
    
    func test_expand_withAuthorize() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        
        controller.onExpand = {
            presenter.dismiss()
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com/authorize?test=test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .webPresenterResultIsNil)
        }
    }
    
    func test_expand_withLogin() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        
        controller.onExpand = {
            presenter.dismiss()
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com/login?test=test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .webPresenterResultIsNil)
        }
    }
    
    func test_expand_withSecurityCheck() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        
        controller.onExpand = {
            presenter.dismiss()
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com?act=security_check")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .webPresenterResultIsNil)
        }
    }
    
    func test_expand_withValidationTest() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(url: url)
        }
        
        controller.onExpand = {
            presenter.dismiss()
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com?api_validation_test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .webPresenterResultIsNil)
        }
    }
    
    func test_handleThreeTimesError() {
        // Given
        let (presenter, controller) = objects
        
        controller.onLoad = { url in
            presenter.handle(error: SessionError.failedAuthorization)
        }
        
        controller.onReload = {
           presenter.handle(error: SessionError.failedAuthorization)
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com?api_validation_test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .failedAuthorization)
        }
    }
    
    func test_dismiss_whenCalledTwice_shouldReturnResult() {
        // Given
        let (presenter, controller) = objects
        var dismissCounter = 0
        
        controller.onLoad = { url in
            presenter.handle(url: url)
            presenter.dismiss()
        }
        
        controller.onDismiss = {
            dismissCounter += 1
        }
        // When
        let result = try? presenter.presentWith(url: URL(string: "http://vk.com#access_token=test")!)
        // Then
        XCTAssertEqual(result, "access_token=test")
    }
    
    func test_dismiss_whenCalledTwice_shouldThrowError() {
        // Given
        let (presenter, controller) = objects
        var dismissCounter = 0
        
        controller.onLoad = { url in
            presenter.dismiss()
            presenter.handle(url: url)
        }
        
        controller.onDismiss = {
            dismissCounter += 1
        }
        // When
        do {
            _ = try presenter.presentWith(url: URL(string: "http://vk.com#access_token=test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .webPresenterResultIsNil)
        }
    }
    
    func test_waitOfUnhandledResponse() {
        // Given
        let (presenter, _) = objects
        let exp = expectation(description: "X")
        exp.isInverted = true
        // When
        DispatchQueue.global().async {
            _ = try? presenter.presentWith(url: URL(string: "http://vk.com?api_validation_test")!)
            exp.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 0.1)
    }
}
