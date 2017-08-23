//import XCTest
//@testable import SwiftyVK
//
//final class DependencyFactoryTests: XCTestCase {
//    
//    private var factory: DependencyFactory {
//        return DependencyFactoryImpl(appId: "1234567890", delegate: SwiftyVKDelegateMock())
//    }
//
//    func test_SessionsHolderType() {
//        XCTAssertTrue(factory.sessionsHolder is SessionsHolderImpl)
//    }
//    
//    func test_SessionImplType() {
//        XCTAssertTrue(factory.session() is SessionImpl)
//    }
//    
//    func test_TaskType() {
//        // When
//        let task = factory.task(
//            request: Request.init(of: .url("")),
//            callbacks: .empty,
//            token: TokenMock(),
//            attemptSheduler: AttemptShedulerMock()
//        )
//        
//        // Then
//        XCTAssertTrue(task is TaskImpl)
//    }
//    
//    func test_TokenType() {
//        // When
//        let token = factory.token(token: "", expires: 0, info: [:])
//        // Then
//        XCTAssertTrue(token is TokenImpl)
//    }
//}
