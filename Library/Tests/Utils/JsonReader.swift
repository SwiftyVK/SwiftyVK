import Foundation
import XCTest
@testable import SwiftyVK

final class JsonReader {
    
    static func read(_ name: String, file: StaticString = #file, line: UInt = #line) -> Data? {
        let bundle = Bundle(for: JsonReader.self)
        
        guard let filePath = bundle.path(forResource: name, ofType: "json") else {
            XCTFail("JSON file not found", file: file, line: line)
            return nil
        }
        
        let fileUrl = URL(fileURLWithPath: filePath)
        
        do {
            return try Data(contentsOf: fileUrl)
        } catch let error {
            XCTFail("JSON file not read with error: \(error)", file: file, line: line)
            return nil
        }
    }
}

extension Data {
    
    func toJson(file: StaticString = #file, line: UInt = #line) -> JSON? {
        do {
            let json = try JSON(data: self)
            return json
        } catch let error {
            XCTFail("JSON not parsed with error: \(error)", file: file, line: line)
            return nil
        }
    }
}
