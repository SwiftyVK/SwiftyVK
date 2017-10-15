import Foundation
import XCTest
@testable import SwiftyVK

final class ResourcesTests: XCTestCase {
    
    func test_suffixForPlatform() {
        // When
        let path = Resources.withSuffix("test")
        // Then
        #if os(macOS)
            XCTAssertEqual(path, "test_macOS")
        #elseif os(iOS)
            XCTAssertEqual(path, "test_iOS")
        #elseif os(tvOS)
            XCTAssertEqual(path, "test_tvOS")
        #elseif os(watchOS)
            XCTAssertEqual(path, "test_watchOS")
        #endif
    }
}
