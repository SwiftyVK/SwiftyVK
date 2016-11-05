extension VK {
    public struct config {
        //Returns used VK API version
        public static var apiVersion = "5.53"
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
        
        public static var language: String? {
            get {
                if useSystemLanguage {
                    let syslemLang = Bundle.preferredLocalizations(from: supportedLanguages).first
                    
                    if syslemLang == "uk" {
                        return "ua"
                    }
                    
                    return syslemLang
                }
                return self.selectedLanguage
            }
            
            set {
                guard newValue == nil || supportedLanguages.contains(newValue!) else {return}
                self.selectedLanguage = newValue
                useSystemLanguage = (newValue == nil)
            }
        }
        internal static let supportedLanguages = ["ru", "uk", "be", "en", "es", "fi", "de", "it"]
        internal static var useSystemLanguage = true
        private static var selectedLanguage: String?
    }
}
