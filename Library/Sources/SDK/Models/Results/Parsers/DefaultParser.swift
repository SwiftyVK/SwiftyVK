import Foundation

class DefaultParser: SwiftyVkParser {
    
    func parse(_ data: Data) -> Response<Data, NSError> {
        return .success(data)
    }
}
