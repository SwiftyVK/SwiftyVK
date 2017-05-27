import XCTest
@testable import SwiftyVK

final class DependencyBoxTests: BaseTestCase {
    
    private var box: DependencyBox {
        return DependencyBoxImpl()
    }

    func test_SessionStorageType() {
        XCTAssertTrue(box.sessionStorage is SessionStorageImpl)
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
        XCTAssertTrue(task is TaskImpl)
    }
    
    func test_TokenType() {
        // When
        let token = box.token(token: "", expires: 0, info: [:])
        // Then
        XCTAssertTrue(token is TokenImpl)
    }
}
