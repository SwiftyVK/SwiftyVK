public enum GenericResult<Result, Error> {
    case result(Result)
    case error(Error)
}
