import XCTest
@testable import SwiftyVK

final class DependencyBoxTests: BaseTestCase {
    
    private var box: DependencyBox {
        return DependencyBoxImpl()
    }

    func test_SessionManager() {
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
}
