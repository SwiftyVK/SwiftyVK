@testable import SwiftyVK

final class BodyBuilderMock: BodyBuilder {
    
    let boundary = "boundary"
    
    var makeBodyCallCount = 0
    
    func makeBody(from media: [Media]) -> Data {
        makeBodyCallCount += 1
        return Data()
    }
}
