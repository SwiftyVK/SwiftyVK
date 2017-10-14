@testable import SwiftyVK

final class MultipartBodyBuilderMock: MultipartBodyBuilder {
    
    let boundary = "boundary"
    
    let data = "data".data(using: .utf8)!
    var makeBodyCallCount = 0
    
    func makeBody(from media: [Media], partType: PartType) -> Data {
        makeBodyCallCount += 1
        return data
    }
}
