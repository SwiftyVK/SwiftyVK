import Foundation

private var tokenInstance: LegacyToken? {
willSet {
    if tokenInstance != nil && newValue == nil {
        VK.delegate?.vkDidUnauthorize()
    }
}
didSet {
    if oldValue == nil, let tokenInstance = tokenInstance {
        VK.delegate?.vkDidAuthorizeWith(parameters: tokenInstance.parameters)
    }
}
}

class LegacyToken: NSObject, NSCoding {

    private(set) static var revoke = true

    private static let keychainParams = [
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: "SwiftyVK",
        kSecAttrAccount: VK.appID ?? ""
        ] as NSDictionary

    private var token: String
    private var expires: Int
    private var infinite = false
    fileprivate var parameters: [String: String]

    override var description: String {
        return "Token with parameters: \(parameters))"
    }

    convenience init(fromResponse response: String) {
        let parameters  = LegacyToken.parseParametersFrom(response: response)
        let token       = parameters["access_token"] ?? ""
        let expiresIn   = Int(parameters["expires_in"] ?? "-1") ?? -1

        self.init(fromRawToken: token, expiresIn: expiresIn, params: parameters)
    }
    
    init(fromRawToken rawToken: String, expiresIn: Int, params: [String: String] = [:]) {
        token           = rawToken
        expires         = Int(Date().timeIntervalSince1970) + expiresIn
        infinite        = expiresIn == 0
        parameters      = params
        
        super.init()
        tokenInstance = self
        LegacyToken.revoke = true
        VK.Log.put("Token", "init \(self)")
        save()
    }

    class func get() -> String? {
        VK.Log.put("Token", "getting")

        if let tokenInstance = tokenInstance, tokenInstance.valid {
            return tokenInstance.token
        }
        else if let tokenInstance = _load(), tokenInstance.valid {
            return tokenInstance.token
        }
        
        return nil
    }
    
    private var valid: Bool {
        if infinite || expires > Int(Date().timeIntervalSince1970) {
            return true
        }
        
        VK.Log.put("Token", "expired")
        LegacyToken.revoke = false
        LegacyToken.remove()
        
        return (LegacyAuthorizator.authorize() == nil)
    }

    class var exist: Bool {
        return tokenInstance != nil
    }

    private class func parseParametersFrom(response: String) -> [String : String] {
        let fragment    = response.components(separatedBy: "#")[1]
        let queryItems  = fragment.components(separatedBy: "&")
        var parameters  = [String: String]()

        for keyValueString in queryItems {
            let keyValueArray = keyValueString.components(separatedBy: "=")
            parameters[keyValueArray[0]] = keyValueArray[1]
        }
        
        VK.Log.put("Token", "parse from parameters: \(parameters)")
        return parameters
    }

    private class func _load() -> LegacyToken? {
        if let token = loadFromKeychain() {
            tokenInstance = token
            return tokenInstance
        }

        if tokenInstance == nil {
            VK.Log.put("Token", " not saved yet in storage")
        }

        return tokenInstance
    }

    private static func loadFromKeychain() -> LegacyToken? {
        guard let keychainQuery = (LegacyToken.keychainParams.mutableCopy() as? NSMutableDictionary) else {return nil}
        
        keychainQuery.setObject(kCFBooleanTrue, forKey: NSString(format: kSecReturnData))
        keychainQuery.setObject(kSecMatchLimitOne, forKey: NSString(format: kSecMatchLimit))

        var keychainResult: AnyObject?

        guard
            SecItemCopyMatching(keychainQuery, &keychainResult) == .allZeros,
            let data = keychainResult as? Data,
            let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? LegacyToken
            else {return nil}

        VK.Log.put("Token", "loaded from keychain")
        return token
    }

    func save() {
        LegacyToken.removeSavedData()

        guard let keychainQuery = (LegacyToken.keychainParams.mutableCopy() as? NSMutableDictionary) else {
            VK.Log.put("Token", "not saved to keychain. Query is empty")
            return
        }
        
        keychainQuery.setObject(NSKeyedArchiver.archivedData(withRootObject: self), forKey: NSString(format: kSecValueData))

        let keychainCode = SecItemAdd(keychainQuery, nil)
        
        guard keychainCode == .allZeros else {
            VK.Log.put("Token", "not saved to keychain with error code \(keychainCode)")
            return
        }
        
        VK.Log.put("Token", "saved to keychain")
    }

    class func remove() {
        removeSavedData()
        tokenInstance = nil
        VK.Log.put("Token", "removed")
    }

    private class func removeSavedData() {
        SecItemDelete(keychainParams)
    }

    deinit {VK.Log.put("Token", "deinit \(self)")}

    // MARK: - NSCoding protocol
    func encode(with aCoder: NSCoder) {
        aCoder.encode(parameters, forKey: "parameters")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(expires, forKey: "expires")
        aCoder.encode(infinite, forKey: "isOffline")
    }

    required init?(coder aDecoder: NSCoder) {
        token       = aDecoder.decodeObject(forKey: "token") as? String ?? ""
        expires     = aDecoder.decodeInteger(forKey: "expires")
        infinite    = aDecoder.decodeBool(forKey: "isOffline")

        if let parameters = aDecoder.decodeObject(forKey: "parameters") as? [String : String] {
            self.parameters = parameters
        }
        else {
            self.parameters = [:]
        }
    }
}
