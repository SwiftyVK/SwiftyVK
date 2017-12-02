import XCTest
@testable import SwiftyVK

final class TaskShedulerTests: XCTestCase {
    
    func test_exeuteAllOperations_forCertainTime() {
        // Given
        let group = DispatchGroup()
        for _ in 0..<operationCount { group.enter() }
        // When
        let samples = sheduleSamples(count: operationCount, completion: { group.leave() })
        _ = group.wait(timeout: .now() + totalRunTime)
        // Then        
        XCTAssertEqual(
            samples.filter {$0.isFinished} .count,
            operationCount,
            "All concurrent operations should be executed"
        )
    }
    
    override func setUp() {
        sheduler = TaskShedulerImpl()
    }
    
    override func tearDown() {
        sheduler = nil
    }
}

private var sheduler: TaskShedulerImpl?

private let operationCount = 100

private var totalRunTime: TimeInterval {
    return TaskMock().runTime*Double(operationCount)
}

private func sheduleSamples(count: Int, completion: (() -> ())? = nil) -> [TaskMock] {
    let samples = (0..<count).map { _ in TaskMock(completion: completion) }
    samples.forEach { sheduler?.shedule(task: $0) }
    return samples
}
