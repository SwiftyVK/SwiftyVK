import XCTest
@testable import SwiftyVK

final class TaskShedulerTests: XCTestCase {
    
    func test_concurrentShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let tasks = (0..<100).map { _ in TaskMock() }
        
        // When
        tasks.forEach { task in
            try! sheduler.shedule(task: task, concurrent: true)
        }
        
        // Then
        Thread.sleep(forTimeInterval: tasks.first!.delay*2)
        
        tasks.forEach { task in
            XCTAssertTrue(task.isFinished)
        }
    }
    
    func test_serialShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let tasks = (0..<100).map { _ in TaskMock() }
        
        // When
        tasks.forEach { task in
            try! sheduler.shedule(task: task, concurrent: false)
        }
        
        // Then
        Thread.sleep(forTimeInterval: tasks.first!.delay*2)
        
        let finished = tasks.filter { $0.isFinished }
        XCTAssertLessThan(finished.count, 100)
    }
    
    func test_randomShedule() {
        // Given
        let sheduler = TaskShedulerImpl()
        let serialTasks = (0..<100).map { _ in TaskMock() }
        let concurrentTasks = (0..<100).map { _ in TaskMock() }
        let allTasks = serialTasks.map { ($0, false) } + concurrentTasks.map { ($0, true) }
        
        // When
        allTasks.forEach { task in
            try! sheduler.shedule(task: task.0, concurrent: task.1)
        }
        
        // Then
        Thread.sleep(forTimeInterval: serialTasks.first!.delay*2)
        
        let serialFinished = serialTasks.filter { $0.isFinished }
        XCTAssertLessThan(serialFinished.count, 100)
        
        concurrentTasks.forEach { task in
            XCTAssertTrue(task.isFinished)
        }
    }
    
    func test_sheduleWrong() {
        // Given
        let sheduler = TaskShedulerImpl()
        let wrongTask = WrongTaskMock()
        
        do {
            // When
            try sheduler.shedule(task: wrongTask, concurrent: false)
        } catch let error {
            // Then
            XCTAssertEqual(error as? RequestError, .wrongTaskType)
        }
    }
}
