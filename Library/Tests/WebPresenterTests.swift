import XCTest
@testable import SwiftyVK

final class WebPresenterTests: XCTestCase {
    
    func makeContext() -> (presenter: WebPresenter, webControllerMaker: WebControllerMakerMock) {
        let controllerMaker = WebControllerMakerMock()
        let presenter = WebPresenterImpl(
            uiSyncQueue: DispatchQueue.global(),
            controllerMaker: controllerMaker,
            maxFails: 3,
            timeout: 1
        )
        return (presenter, controllerMaker)
    }
    
    private func urlRequest(string: String) -> URLRequest? {
        return URL(string: string).flatMap { URLRequest(url: $0) }
    }
    
    func test_load_returnToken_whenTokenRecieved() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()

            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(
            urlRequest: urlRequest(string: "http://vk.com#access_token=test")!
        )
        // Then
        XCTAssertEqual(result, "access_token=test")
    }
    
    func test_load_returnCode_whenCodeRecieved() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()

            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(
            urlRequest: urlRequest(string: "http://vk.com#code=test")!
        )
        // Then
        XCTAssertEqual(result, "code=test")
    }
    
    func test_load_throwWrongAuthUrl_whenUrlIsNil() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(nil))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#access_denied")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.authorizationUrlIsNil)
        }
    }
    
    func test_load_throwWebPresenterTimedOut_whenTimeOut() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            return WebControllerMock()
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#access_denied")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.webPresenterTimedOut)
        }
    }
    
    func test_load_throwDeniedfromUser_whenAccessDenied() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#access_denied")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.authorizationDenied)
        }
    }
    
    func test_load_throwCancelled_whenFlowCancelled() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#cancel=1")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.authorizationCancelled)
        }
    }
    
    func test_load_throwFailedAuthorization_whenFlowFailed() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#fail=1")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.authorizationFailed)
        }
    }
    
    func test_load_returnSuccess_whenValidationSuccess() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#success=1")!)
        // Then
        XCTAssertEqual(result, "success=1")
    }
    
    func test_load_callGoBackOnce_whenOpenThirdpartyUrl() {
        // Given
        let context = makeContext()
        var goBackCallCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            var onResultBlock: ((WebControllerResult) -> ())?
            
            controller.onLoad = { url, onResult in
                onResultBlock = onResult
                
                var nerUrl = url
                
                if url?.path == "/test1" {
                    nerUrl = URL(string: "http://test.ru")!
                }
                
                onResultBlock?(.response(nerUrl))
            }
            
            controller.onGoBack = {
                goBackCallCount += 1
                DispatchQueue.global().async {
                    onResultBlock?(.response(URL(string: "http://vk.com#success=1")!))
                }
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com/test1")!)
        // Then
        XCTAssertEqual(result, "success=1")
        XCTAssertEqual(goBackCallCount, 1)
    }
    
    func test_throwFailedAuthorization_whenLoadFailtThreeTimes() {
        // Given
        let context = makeContext()
        var loadCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            var onResultBlock: ((WebControllerResult) -> ())?
            
            controller.onLoad = { url, onResult in
                loadCount += 1
                onResultBlock = onResult
                onResultBlock?(.error(.authorizationFailed))
            }
            
            controller.onReload = {
                loadCount += 1
                onResultBlock?(.error(.authorizationFailed))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com?api_validation_test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.authorizationFailed)
            XCTAssertEqual(loadCount, 3)
        }
    }
    
    func test_dismiss_returnsResult_whenCalledAfterGiveResult() {
        // Given
        let context = makeContext()
        var dismissCounter = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    context.presenter.dismiss()
                }
            }
            
            controller.onDismiss = {
                dismissCounter += 1
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#access_token=test")!)
        // Then
        XCTAssertEqual(result, "access_token=test")
    }
    
    func test_dismiss_throwsError_whenCalledBeforeGiveResult() {
        // Given
        let context = makeContext()
        var dismissCounter = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                context.presenter.dismiss()
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    onResult(.response(url))
                }
            }
            
            controller.onDismiss = {
                dismissCounter += 1
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#access_token=test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVK, VKError.webPresenterResultIsNil)
        }
    }
    
    func test_deinit_controllerInMainThread() throws {
        // Given
        let context = makeContext()
        let exp = expectation(description: "")
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult in
                onResult(.response(url))
            }
            
            controller.onDeinit = {
                // Then
                XCTAssertTrue(Thread.isMainThread)
                exp.fulfill()
            }
            
            return controller
        }
        
        // When
        DispatchQueue.global().async {
            _ = try? context.presenter.presentWith(urlRequest: self.urlRequest(string: "http://vk.com#access_token=test")!)
        }
        
        waitForExpectations(timeout: 10)
    }
}


