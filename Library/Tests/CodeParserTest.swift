//
//  CodeParserTest.swift
//  SwiftyVK
//
//  Created by PeterSamokhin on 30.03.2020.
//

import XCTest
@testable import SwiftyVK

final class CodeParserTests: XCTestCase {
    
    func test_parseValidToken() {
        // Given
        let parser = CodeParserImpl()
        let info = "code=1234567890&info=testInfo"
        // When
        let result = parser.parse(codeInfo: info)
        // Then
        XCTAssertEqual(result?.code, "1234567890")
        XCTAssertEqual(result?.info ?? [:], ["info": "testInfo", "code": "1234567890"])
    }
    
    func test_parseWithoutToken() {
        // Given
        let parser = CodeParserImpl()
        let info = "info=testInfo"
        // When
        let result = parser.parse(codeInfo: info)
        // Then
        XCTAssertNil(result)
    }
}
