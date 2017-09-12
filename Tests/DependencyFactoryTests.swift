import Foundation
import XCTest
@testable import SwiftyVK

class DependencyFactoryTests: XCTestCase {
    
    func test_maleAuthorizator_typeIsAuthorizatorImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.authorizator
        // Then
        XCTAssertTrue(type(of: object) == AuthorizatorImpl.self)
    }
    
    func test_makeAttempt_typeIsAttemptImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.attempt(request: URLRequest(url: URL(fileURLWithPath: "")), timeout: 0, callbacks: .default)
        // Then
        XCTAssertTrue(type(of: object) == AttemptImpl.self)
    }
    
    func test_makeSession_typeIsSessionImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.session(id: "", config: .default, sessionSaver: SessionsHolderMock())
        // Then
        XCTAssertTrue(type(of: object) == SessionImpl.self)
    }
    
    func test_makeWebController_typeIsWebControllerPLATFORM() {
        // Given
        let context = makeContext()
        // When
        guard let object = context.factory.webController() else {
            return XCTFail("Object not created")
        }
        // Then
        #if os(iOS)
            XCTAssertTrue(type(of: object) == WebControllerIOS.self)
        #elseif os(macOS)
            XCTAssertTrue(type(of: object) == WebControllerMacOS.self)
        #endif
    }
    
    func test_makeCaptchaController_typeIsCaptchaControllerPLATFORM() {
        // Given
        let context = makeContext()
        // When
        guard let object = context.factory.captchaController() else {
            return XCTFail("Object not created")
        }
        // Then
        #if os(iOS)
            XCTAssertTrue(type(of: object) == CaptchaControllerIOS.self)
        #elseif os(macOS)
            XCTAssertTrue(type(of: object) == CaptchaControllerMacOS.self)
        #endif
    }
    
    func test_makeTask_typeIsTaskImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.task(request: Request(type: .url("")), session: SessionMock())
        // Then
        XCTAssertTrue(type(of: object) == TaskImpl.self)
    }
    
    func test_longPollTask_typeIsLongPollTaskImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.longPollTask(
            session: SessionMock(),
            data: LongPollTaskData(server: "", startTs: "", lpKey: "", onResponse: { _ in }, onKeyExpired: {})
        )
        // Then
        XCTAssertTrue(type(of: object) == LongPollTaskImpl.self)
    }
    
    func test_makeLongPoll_typeIsLongPollImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.longPoll(session: SessionMock())
        // Then
        XCTAssertTrue(type(of: object) == LongPollImpl.self)
    }
    
    func test_makeToken_typeIsTokenImpl() {
        // Given
        let context = makeContext()
        // When
        let object = context.factory.token(token: "", expires: 0, info: [:])
        // Then
        XCTAssertTrue(type(of: object) == TokenImpl.self)
    }
}

private func makeContext() -> (factory: DependencyFactoryImpl, delegate: SwiftyVKDelegateMock) {
    let delegate = SwiftyVKDelegateMock()
    let factory = DependencyFactoryImpl(appId: "123", delegate: delegate)
    
    return (factory, delegate)
}
