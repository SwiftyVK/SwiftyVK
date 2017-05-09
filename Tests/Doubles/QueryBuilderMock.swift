@testable import SwiftyVK

final class QueryBuilderMock: QueryBuilder {
    
    let parameters = "parameters"
    var makeQueryCallCount = 0
    
    func makeQuery(from parameters: Parameters, config: Config = .default, captcha: Captcha?) -> String {
        makeQueryCallCount += 1
        return self.parameters
    }
}
