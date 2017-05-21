import XCTest
@testable import SwiftyVK

final class DependencyBoxTests: BaseTestCase {
    
    private var box: DependencyBox {
        return DependencyBoxImpl()
    }

    func test_SessionManagerType() {
        XCTAssertTrue(box.sessionManager is SessionManagerImpl)
    }
    
    func test_SessionImplType() {
        XCTAssertTrue(box.session() is SessionImpl)
    }
    
    func test_TaskType() {
        // When
        let task = box.task(
            request: Request.init(of: .url("")),
            callbacks: .empty,
            attemptSheduler: AttemptShedulerMock()
        )
        
        // Then
        XCTAssertTrue(task is TaskImpl<AttemptImpl>)
    }
    
    func test_TokenType() {
        // When
        let token = box.token(token: "", expires: 0, info: [:])
        // Then
        XCTAssertTrue(token is TokenImpl)
    }
    
    func test_AuthorizatorType() {
        // When
        let authorizator = box.authorizator()
        // Then
        XCTAssertTrue(authorizator is AuthorizatorImpl)
    }
}
