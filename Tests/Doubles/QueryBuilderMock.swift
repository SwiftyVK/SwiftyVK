@testable import SwiftyVK

final class QueryBuilderMock: QueryBuilder {
    
    var makeQueryCallCount = 0
    
    func makeQuery(from parameters: Parameters) -> String {
        makeQueryCallCount += 1
        return "parameters"
    }
}
