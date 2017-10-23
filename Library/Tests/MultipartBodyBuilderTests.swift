import XCTest
@testable import SwiftyVK

final class MultipartBodyBuilderTests: XCTestCase {
    
    var builder: MultipartBodyBuilderImpl {
        return MultipartBodyBuilderImpl()
    }
    
    var data = "BinaryData".data(using: .utf8)!
    
    private func splitByLines(string: String) -> [String] {
        return string.components(separatedBy: "\n")
    }
    
    func test_emptyData() {
        // When
        let sample = builder.makeBody(from: [], partType: .file)
        
        // Then
        XCTAssertTrue(sample.isEmpty)
    }
    
    func test_dataFormat() {
        // Given
        let media1 = Media.image(data: data, type: .jpg)
        let media2 = Media.video(data: data)
        
        // When
        let sample = builder.makeBody(from: [media1, media2], partType: .file).toString().splitByLines()
        
        // Then
        XCTAssertEqual(sample[0], "")
        XCTAssertEqual(sample[1], "--\(builder.boundary)")
        
        XCTAssertEqual(sample[2], "Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"")
        XCTAssertEqual(sample[3], "Content-Type: document/other")
        XCTAssertEqual(sample[4], "")
        XCTAssertEqual(sample[5], data.toString())
        
        XCTAssertEqual(sample[6], "--\(builder.boundary)")
        
        XCTAssertEqual(sample[7], "Content-Disposition: form-data; name=\"file\"; filename=\"file.video\"")
        XCTAssertEqual(sample[8], "Content-Type: document/other")
        XCTAssertEqual(sample[9], "")
        XCTAssertEqual(sample[10], data.toString())
        
        XCTAssertEqual(sample[11], "--\(builder.boundary)--\r")
    }
    
    func test_indexedFilePartType() {
        // Given
        let media = Media.image(data: data, type: .jpg)
        
        // When
        let sample = builder.makeBody(from: [media], partType: .indexedFile).toString().splitByLines()
        
        // Then
        XCTAssertEqual(sample[2], "Content-Disposition: form-data; name=\"file0\"; filename=\"file.jpg\"")
    }
    
    func test_videoPartType() {
        // Given
        let media = Media.image(data: data, type: .jpg)
        
        // When
        let sample = builder.makeBody(from: [media], partType: .video).toString().splitByLines()
        
        // Then
        XCTAssertEqual(sample[2], "Content-Disposition: form-data; name=\"video_file\"; filename=\"file.jpg\"")
        
    }
    
    
    func test_photoPartType() {
        // Given
        let media = Media.image(data: data, type: .jpg)
        
        // When
        let sample = builder.makeBody(from: [media], partType: .photo).toString().splitByLines()
        
        // Then
        XCTAssertEqual(sample[2], "Content-Disposition: form-data; name=\"photo\"; filename=\"file.jpg\"")
    }
}

private extension Data {
    func toString() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

private extension String {
    func splitByLines() -> [String] {
        return self.components(separatedBy: "\r\n")
    }
}
