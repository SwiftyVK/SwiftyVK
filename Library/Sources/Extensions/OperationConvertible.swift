public protocol OperationConvertible {
    func toOperation() -> Operation
    func cancel()
}

extension OperationConvertible where Self: Operation {
    func toOperation() -> Operation {
        return self
    }
}
