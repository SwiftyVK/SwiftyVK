extension Error {
    func toVK() -> VKError {
        if let vkError = self as? VKError {
            return vkError
        }
        else if let apiError = self as? ApiError {
            return .api(apiError)
        }
        else {
            return .unknown(self)
        }
    }
}
