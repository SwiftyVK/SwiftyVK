@testable import SwiftyVK

final class BodyBuilderMock: BodyBuilder {
    
    let boundary = "boundary"
    
    let data = "data".data(using: .utf8)!
    var makeBodyCallCount = 0
    
    func makeBody(from media: [Media]) -> Data {
        makeBodyCallCount += 1
        return data
    }
}
