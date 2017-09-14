import Foundation
import XCTest
@testable import SwiftyVK

class TaskTests: XCTestCase {
    
    func test_callSessionShedule() {
        // Given
        var sessionSheduleCallCount = 0
        let context = makeContext(configure: { $0.onFinish(.emptySuccess) })
        context.session.onShedule = { _ in
            sessionSheduleCallCount += 1
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(sessionSheduleCallCount, 1)
    }
    
    func test_callbacksContainData_whenAttemptGivesError() {
        // Given
        var givenData: Data?
        let context = makeContext(
            configure: { $0.onFinish(.emptySuccess) },
            callbacks: RequestCallbacks( onSuccess: { givenData = $0 })
        )
        // When
        context.task.main()
        // Then
        XCTAssertEqual(givenData, Data())
    }
    
    func test_callbacksContainError_whenAttemptGivesError() {
        // Given
        var givenError: VKError?
        let context = makeContext(
            configure: { $0.onFinish(.unexpectedError) },
            callbacks: RequestCallbacks( onError: { givenError = $0 })
        )
        // When
        context.task.main()
        // Then
        XCTAssertEqual(givenError, .unexpectedResponse)
    }
    
    func test_callbacksContainsRecievedBytes_whenAttemptRecieveBytes() {
        // Given
        var progressResult: (type: ProgressType, current: Int64, total: Int64)?
        let context = makeContext(
            configure: {
                $0.onRecive(100, 1000)
                $0.onFinish(.unexpectedError)
        },
            callbacks: RequestCallbacks(onProgress: { progressResult = $0 })
        )
        // When
        context.task.main()
        // Then
        XCTAssertEqual(progressResult?.type, .recieved)
        XCTAssertEqual(progressResult?.current, 100)
        XCTAssertEqual(progressResult?.total, 1000)
    }
    
    func test_callbacksContainsSendedBytes_whenAttemptSentBytes() {
        // Given
        var progressResult: (type: ProgressType, current: Int64, total: Int64)?
        let context = makeContext(
            configure: {
                $0.onSent(100, 1000)
                $0.onFinish(.unexpectedError)
        },
            callbacks: RequestCallbacks(onProgress: { progressResult = $0 })
        )
        // When
        context.task.main()
        // Then
        XCTAssertEqual(progressResult?.type, .sended)
        XCTAssertEqual(progressResult?.current, 100)
        XCTAssertEqual(progressResult?.total, 1000)
    }
    
    func test_callbacksNotCalled_whenTaskCancelled() {
        // Given
        var callbacksCalled = false
        let context = makeContext(
            configure: { $0.onFinish(.emptySuccess) },
            callbacks: RequestCallbacks(
                onSuccess: { _ in callbacksCalled = true },
                onError: { _ in callbacksCalled = true },
                onProgress: { _,_,_ in callbacksCalled = true }
            ),
            shouldCancel: true
        )
        
        // When
        context.task.main()
        // Then
        XCTAssertFalse(callbacksCalled)
    }
    
    func test_resendCount_withErrorHandling() {
        // Given
        let error = ApiError(code: 0).toVK
        var sessionSheduleCallCount = 0
        let context = makeContext(configure: { $0.onFinish(.error(error)) })
        
        context.session.onShedule = { _ in
            sessionSheduleCallCount += 1
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(sessionSheduleCallCount, 3)
    }
    
    func test_resendCount_withoutErrorHandling() {
        // Given
        let error = ApiError(code: 0).toVK
        var sessionSheduleCallCount = 0
        let context = makeContext(
            configure: { $0.onFinish(.error(error)) },
            handleErrors: false
        )
        
        context.session.onShedule = { _ in
            sessionSheduleCallCount += 1
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(sessionSheduleCallCount, 1)
    }
    
    func test_errorHandlerCallCount_withErrorHandling() {
        // Given
        let error = ApiError(code: 0).toVK
        var errorHandlerCallCount = 0
        let context = makeContext(configure: { $0.onFinish(.error(error)) })
        
        context.errorHandler.onHandle = {
            errorHandlerCallCount += 1
            return .none
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(errorHandlerCallCount, 3)
    }
    
    func test_errorHandlerCallCount_withoutErrorHandling() {
        // Given
        let error = ApiError(code: 0).toVK
        var errorHandlerCallCount = 0
        let context = makeContext(
            configure: { $0.onFinish(.error(error)) },
            handleErrors: false
        )
        
        context.errorHandler.onHandle = {
            errorHandlerCallCount += 1
            return .none
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(errorHandlerCallCount, 0)
    }
    
    func test_capthchaDismissed_whenRequestContainsCaptcha() {
        // Given
        let error = ApiError(code: 0).toVK
        var errorHandlerCalled = false
        var dismissCaptchaCallCount = 0
        let context = makeContext(configure: { $0.onFinish(.error(error)) })
        
        context.errorHandler.onHandle = {
            if errorHandlerCalled {
                return .none
            }
            
            errorHandlerCalled = true
            return .captcha(Captcha(sid: "", key: ""))
        }
        
        context.session.onDismissCaptcha = {
            dismissCaptchaCallCount += 1
        }
        // When
        context.task.main()
        // Then
        XCTAssertEqual(dismissCaptchaCallCount, 1)
    }
    
    func test_resendCount_withChainedRequests() {
        // Given
        var sessionSheduleCallCount = 0
        let context = makeContext(
            configure: { $0.onFinish(.emptySuccess) },
            nextRequest: VKAPI.Users.get(.empty)
        )
        
        context.session.onShedule = { _ in
            sessionSheduleCallCount += 1
        }
        
        // When
        context.task.main()
        // Then
        XCTAssertEqual(sessionSheduleCallCount, 2)
    }
    
    func test_catchAnyError_whenThrows() {
        // Given
        var givenError: VKError?
        let context = makeContext(
            configure: { $0.onFinish(.emptySuccess) },
            callbacks: RequestCallbacks( onError: { givenError = $0 })
        )
        
        context.requestBuilder.onBuild = {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        // When
        context.task.main()
        // Then
        XCTAssertEqual(givenError, .unknown(NSError(domain: "", code: 0, userInfo: nil)))
    }
    
    func test_catchVKError_whenThrows() {
        // Given
        var givenError: VKError?
        let context = makeContext(
            configure: { $0.onFinish(.emptySuccess) },
            callbacks: RequestCallbacks( onError: { givenError = $0 })
        )
        
        context.requestBuilder.onBuild = {
            throw VKError.unexpectedResponse
        }
        
        // When
        context.task.main()
        // Then
        XCTAssertEqual(givenError, .unexpectedResponse)
    }
    
    func test_description() {
        // When
        let context = makeContext()
        // Then
        XCTAssertEqual(context.task.description, "task #1, state: created")
    }
}

private func makeContext(
    configure: ((AttemptCallbacks) -> ())? = nil,
    callbacks: RequestCallbacks = .empty,
    handleErrors: Bool = true,
    shouldCancel: Bool = false,
    nextRequest: ChainableMethod? = nil
    ) -> (
    task: TaskImpl,
    requestBuilder: URLRequestBuilderMock,
    session: SessionMock,
    errorHandler: ApiErrorHandlerMock
    ) {
        let urlRequestBuilder = URLRequestBuilderMock()
        let taskSession = SessionMock()
        let attemptMaker = AttemptMakerMock()
        let apiErrorHandler = ApiErrorHandlerMock()
        var request = VKAPI.Users.get(.empty)
            .configure(with: Config(handleErrors: handleErrors))
        
        if let nextRequest = nextRequest {
            request = request.chain { _ in nextRequest }
        }
        
        let _request = request.toRequest()
        _request.callbacks = callbacks
        
        let task = TaskImpl(
            id: 1,
            request: _request,
            session: taskSession,
            urlRequestBuilder: urlRequestBuilder,
            attemptMaker: attemptMaker,
            apiErrorHandler: apiErrorHandler
        )
        
        attemptMaker.onMake = { callbacks in
            if shouldCancel { task.cancel() }
            configure?(callbacks)
            return AttemptMock()
        }
        
        return (task, urlRequestBuilder, taskSession, apiErrorHandler)
}

