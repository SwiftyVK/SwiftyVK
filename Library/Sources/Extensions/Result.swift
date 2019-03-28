extension Result {
    func unwrap() throws -> Success {
        switch self {
        case let .success(data):
            return data
        case let .failure(error):
            throw error
        }
    }
}
