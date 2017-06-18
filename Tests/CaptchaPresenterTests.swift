import Foundation
import XCTest
@testable import SwiftyVK

class CaptchaPresenterTests: XCTestCase {
    
    func makeContext() -> (presenter: CaptchaPresenter, webControllerMaker: CaptchaControllerMakerMock) {
        let controllerMaker = CaptchaControllerMakerMock()
        
        let presenter = CaptchaPresenterImpl(
            uiSyncQueue: DispatchQueue.global(),
            controllerMaker: controllerMaker,
            timeout: 1
        )
        return (presenter, controllerMaker)
    }
    
    
    func test_present_throwCantMakeCaptchaController() {
        // Given
        let context = makeContext()
        // When
        do {
            _ = try context.presenter.present(rawCaptchaUrl: "", dismissOnFinish: false)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .cantMakeCaptchaController)
        }
    }
    
    func test_present_controllerPrepareCalledOnce() {
        // Given
        let context = makeContext()
        var prepareForPresentCallCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = CaptchaControllerMock()
            
            controller.onPrepareForPresent = {
                prepareForPresentCallCount += 1
            }
            
            return controller
        }
        // When
        _ = try? context.presenter.present(rawCaptchaUrl: "", dismissOnFinish: false)
        // Then
        XCTAssertEqual(prepareForPresentCallCount, 1)
    }
    
    func test_present_throwCantLoadCaptchaImage_whenUrlIsWrong() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            return CaptchaControllerMock()
        }
        // When
        do {
            _ = try context.presenter.present(rawCaptchaUrl: "", dismissOnFinish: false)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .cantLoadCaptchaImage)
        }
    }
    
    func test_present_throwCantCaptchaPresenterTimedOut() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            return CaptchaControllerMock()
        }
        // When
        do {
            _ = try context.presenter.present(rawCaptchaUrl: "http://vk.com", dismissOnFinish: false)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .captchaPresenterTimedOut)
        }
    }
    
    func test_present_returnsResult_whenGiveResult() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = CaptchaControllerMock()
            
            controller.onPresent = { data, onResult, onDismiss in
                onResult("test")
            }
            
            return controller
            
        }
        // When
        let result = try? context.presenter.present(rawCaptchaUrl: "http://vk.com", dismissOnFinish: false)
        // Then
        XCTAssertEqual(result, "test")
    }
    
    func test_present_dismissNotCalled_whenDismissOnFinishIsFalse() {
        // Given
        let context = makeContext()
        var dismissCallCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = CaptchaControllerMock()
            
            controller.onPresent = { data, onResult, onDismiss in
                onResult("test")
            }
            
            controller.onDismiss = {
                dismissCallCount += 1
            }
            
            return controller
            
        }
        // When
        _ = try? context.presenter.present(rawCaptchaUrl: "http://vk.com", dismissOnFinish: false)
        // Then
        XCTAssertEqual(dismissCallCount, 0)
    }
    
    func test_present_dismissCalledOnce_whenDismissOnFinishIsTrue() {
        // Given
        let context = makeContext()
        var dismissCallCount = 0
        
        context.webControllerMaker.onMake = {
            let controller = CaptchaControllerMock()
            
            controller.onPresent = { data, onResult, onDismiss in
                onResult("test")
            }
            
            controller.onDismiss = {
                dismissCallCount += 1
            }
            
            return controller
            
        }
        // When
        _ = try? context.presenter.present(rawCaptchaUrl: "http://vk.com", dismissOnFinish: true)
        // Then
        XCTAssertEqual(dismissCallCount, 1)
    }
    
    func test_present_throwCaptchaFailed_whenControllerDismissed() {
        // Given
        let context = makeContext()
        
        context.webControllerMaker.onMake = {
            let controller = CaptchaControllerMock()
            
            controller.onPresent = { data, onResult, onDismiss in
                context.presenter.dismiss()
            }
            
            return controller
            
        }
        // When
        do {
            _ = try context.presenter.present(rawCaptchaUrl: "http://vk.com", dismissOnFinish: false)
            XCTFail("Expression should throw error")
        } catch let error {
            // Then
            XCTAssertEqual(error as? RequestError, .captchaFailed)
        }
    }
}
