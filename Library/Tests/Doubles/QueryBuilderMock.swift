@testable import SwiftyVK

final class QueryBuilderMock: QueryBuilder {
    
    let parameters = "parameters"
    var makeQueryCallCount = 0
    
    func makeQuery(parameters: Parameters, config: Config, captcha: Captcha?, token: Token?) -> String {
        makeQueryCallCount += 1
        return self.parameters
    }
}
