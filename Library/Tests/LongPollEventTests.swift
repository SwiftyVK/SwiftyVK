import Foundation
import XCTest
@testable import SwiftyVK

final class LongPollEventTests: XCTestCase {
    
    func test_eventsConverting_whenAllUpdatesAreValid() {
        // Given
        guard
            let data = JsonReader.read("longPoll.updates"),
            let json: [Any] = data.toJson()?.array("updates") else {
                return XCTFail()
        }
        let updates = json.compactMap { JSON(value: $0) } .dropFirst().toArray()
        // When
        let events = updates.compactMap { LongPollEvent(json: $0) }
        // Then
        XCTAssertFalse(updates.isEmpty)
        XCTAssertEqual(events.count, updates.count)
        
        for event in events {
            XCTAssertFalse(event.data?.isEmpty ?? true)
        }
    }
    
    func test_eventsConverting_whenUpdateHasWrongType() {
        // Given
        guard
            let data = JsonReader.read("longPoll.updates"),
            let json: [Any] = data.toJson()?.array("updates"),
            let update = json.compactMap({ JSON(value: $0) }).first else {
                return XCTFail()
        }
        // When
        let event = LongPollEvent(json: update)
        // Then
        XCTAssertNil(event)
    }
    
    func test_eventsConverting_whenUpdatesAreEmpty() {
        // Given
        guard
            let data = JsonReader.read("longPoll.empty"),
            let json: [Any] = data.toJson()?.array("updates") else {
                return XCTFail()
        }
        let updates = json.compactMap({ JSON(value: $0) })
        // When
        let events = updates.compactMap { LongPollEvent(json: $0) }
        // Then
        XCTAssertTrue(events.isEmpty)
    }
}
