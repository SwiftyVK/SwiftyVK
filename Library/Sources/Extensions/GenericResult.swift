public enum GenericResult<Result, VkError> {
    case result(Result)
    case error(Error)
}
