// swiftlint:disable type_name
extension VK {
    public struct config {
        //Returns used VK API version
        public static var apiVersion = "5.60"
        //Returns used VK SDK version
        public static let sdkVersion = "1.3.17"
        ///Requests timeout
        public static var timeOut: TimeInterval = 10
        ///Maximum number of attempts to send requests
        public static var maxAttempts: Int = 3
        ///Whether to allow automatic processing of some API error
        public static var catchErrors: Bool = true
        ///Need limit requests per second or not
        public static var useSendLimit: Bool = true
        ///Maximum number of requests send per second
        public static var sendLimit: Int = 3
        ///Allows print log messages to console
        public static var logToConsole: Bool = false
        ///This language will be used in responses from VK
        public static var language: String? {
            get {
                if let selectedLanguage = selectedLanguage {
                    return selectedLanguage
                }
                
                let syslemLang = Bundle.preferredLocalizations(from: supportedLanguages).first
                
                if syslemLang == "uk" {
                    return "ua"
                }
                
                return syslemLang
            }

            set {
                guard let newValue = newValue else {
                    selectedLanguage = nil
                    return
                }
                guard supportedLanguages.contains(newValue) else {
                    return
                }

                self.selectedLanguage = newValue
            }
        }
        internal static let supportedLanguages = ["ru", "uk", "be", "en", "es", "fi", "de", "it"]
        private static var selectedLanguage: String?
    }
}
