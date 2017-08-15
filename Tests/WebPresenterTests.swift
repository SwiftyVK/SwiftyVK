import XCTest
@testable import SwiftyVK

final class WebPresenterTests: BaseTestCase {
    
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
            
            controller.onLoad = { url, onResult, onDismiss in
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
    
    func test_load_throwCantMakeWebViewController_whenControllerDontMake() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            return nil
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#cancel=1")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVk, SessionError.cantMakeWebController.asVk)
        }
    }
    
    func test_load_throwWrongAuthUrl_whenUrlIsNil() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
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
            XCTAssertEqual(error.asVk, SessionError.authorizationUrlIsNil.asVk)
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
            XCTAssertEqual(error.asVk, SessionError.webPresenterTimedOut.asVk)
        }
    }
    
    func test_load_throwDeniedfromUser_whenAccessDenied() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
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
            XCTAssertEqual(error.asVk, SessionError.authorizationDenied.asVk)
        }
    }
    
    func test_load_throwCancelled_whenFlowCancelled() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
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
            XCTAssertEqual(error.asVk, SessionError.authorizationCancelled.asVk)
        }
    }
    
    func test_load_throwFailedAuthorization_whenFlowFailed() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
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
            XCTAssertEqual(error.asVk, SessionError.authorizationFailed.asVk)
        }
    }
    
    func test_load_returnSuccess_whenValidationSuccess() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
                onResult(.response(url))
            }
            
            return controller
        }
        // When
        let result = try? context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com#success=1")!)
        // Then
        XCTAssertEqual(result, "success=1")
    }
    
    func test_load_callGoBackOnce_whenRedirect() {
        // Given
        let context = makeContext()
        var goBackCallCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            var onResultBlock: ((WebControllerResult) -> ())?
            
            controller.onLoad = { url, onResult, onDismiss in
                onResultBlock = onResult
                
                var nerUrl = url
                
                if url?.path == "/test1" {
                    nerUrl = URL(string: "http://vk.com/test2")!
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
            
            controller.onLoad = { url, onResult, onDismiss in
                loadCount += 1
                onResultBlock = onResult
                onResultBlock?(.error(SessionError.authorizationFailed.asVk))
            }
            
            controller.onReload = {
                loadCount += 1
                onResultBlock?(.error(SessionError.authorizationFailed.asVk))
            }
            
            return controller
        }
        // When
        do {
            _ = try context.presenter.presentWith(urlRequest: urlRequest(string: "http://vk.com?api_validation_test")!)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVk, SessionError.authorizationFailed.asVk)
            XCTAssertEqual(loadCount, 3)
        }
    }
    
    func test_dismiss_returnsResult_whenCalledAfterGiveResult() {
        // Given
        let context = makeContext()
        var dismissCounter = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
                onResult(.response(url))
                
                DispatchQueue.global().async {
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
    
    func test_dismiss_returnsResult_whenCalledBeforeGiveResult() {
        // Given
        let context = makeContext()
        var dismissCounter = 0
        
        context.webControllerMaker.onMake = {
            let controller = WebControllerMock()
            
            controller.onLoad = { url, onResult, onDismiss in
                context.presenter.dismiss()
                
                DispatchQueue.global().async {
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
            XCTAssertEqual(error.asVk, SessionError.webPresenterResultIsNil.asVk)
        }
    }
}


