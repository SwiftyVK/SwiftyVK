import XCTest
@testable import SwiftyVK

final class TaskShedulerTests: XCTestCase {
    
    let count = 100
    var totalDelay: TimeInterval {
        return TaskMock().delay*Double(count)
    }
    
    func test_concurrentShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let samples = (0..<100).map { _ in TaskMock() }
        
        // When
        samples.forEach { try! sheduler.shedule(task: $0, concurrent: true) }
        
        // Then
        Thread.sleep(forTimeInterval: totalDelay/10)
        
        XCTAssertEqual(
            samples.map {$0.isFinished},
            (0..<count).map { _ in true },
            "All concurrent operations should be executed"
        )
    }
    
    func test_serialShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let samples = (0..<count).map { _ in TaskMock() }
        
        // When
        samples.forEach { try! sheduler.shedule(task: $0, concurrent: false) }
        
        // Then
        Thread.sleep(forTimeInterval: totalDelay)
        
        XCTAssertLessThan(
            samples.filter { $0.isFinished }.count,
            count,
            "Operations should be executed serially"
        )
        
        Thread.sleep(forTimeInterval: totalDelay)
        
        XCTAssertEqual(
            samples.filter { $0.isFinished }.count,
            count,
            "All operations should be executed"
        )
    }
    
    func test_randomShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let serial = (0..<count).map { _ in TaskMock() }
        let concurrent = (0..<count).map { _ in TaskMock() }
        let samples = serial.map { ($0, false) } + concurrent.map { ($0, true) }
        
        // When
        samples.forEach { try! sheduler.shedule(task: $0.0, concurrent: $0.1) }
        
        // Then
        Thread.sleep(forTimeInterval: totalDelay)
        
        XCTAssertLessThan(
            serial.filter { $0.isFinished }.count,
            count,
            "Operations should be executed serially"
        )
        
        XCTAssertEqual(
            concurrent.map {$0.isFinished},
            (0..<count).map { _ in true },
            "All concurrent operations should be executed"
        )
        
        Thread.sleep(forTimeInterval: totalDelay)
        
        XCTAssertEqual(
            serial.filter { $0.isFinished }.count,
            count,
            "All serial operations should be executed"
        )
    }
    
    func test_wrongShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let sample = WrongTaskMock()
        
        do {
            // When
            try sheduler.shedule(task: sample, concurrent: false)
            XCTFail("Wrong attempt should cause exception")
        } catch let error {
            // Then
            XCTAssertEqual(error.asVk, VkError.wrongTaskType)
        }
    }
}
