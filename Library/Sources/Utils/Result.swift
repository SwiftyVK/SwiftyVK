enum Result<ValueT, ErrorT: Error> {
    case data(ValueT)
    case error(ErrorT)
    
    func unwrap() throws -> ValueT {
        switch self {
        case let .data(data):
            return data
        case let .error(error):
            throw error
        }
    }
}
