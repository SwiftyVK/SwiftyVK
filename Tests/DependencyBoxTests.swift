import XCTest
@testable import SwiftyVK

final class DependencyBoxTests: XCTestCase {
    
    private var box: DependencyBox {
        return DependencyBoxImpl()
    }
    
    
    func test_SessionType() {
        XCTAssertTrue(box.sessionClass() == SessionImpl.self)
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
