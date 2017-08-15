import Foundation

protocol TokenStorage: class {
    func save(token: Token, for sessionId: String) throws
    func getFor(sessionId: String) -> Token?
    func removeFor(sessionId: String)
}

class TokenStorageImpl: TokenStorage {
    
    let serviceKey: String
    
    init(serviceKey: String) {
        self.serviceKey = serviceKey
    }
    
    func save(token: Token, for sessionId: String) throws {
        let keychainQuery = keychainParamsFor(sessionId: sessionId)
        
        keychainQuery.setObject(
            NSKeyedArchiver.archivedData(withRootObject: token), forKey: NSString(format: kSecValueData)
        )
        
        removeFor(sessionId: sessionId)
        
        let keychainCode = SecItemAdd(keychainQuery, nil)
        
        guard keychainCode == 0 else {
            throw SessionError.tokenNotSavedInStorage.asVk
        }
    }
    
    func getFor(sessionId: String) -> Token? {
        let keychainQuery = keychainParamsFor(sessionId: sessionId)
        
        keychainQuery.setObject(kCFBooleanTrue, forKey: NSString(format: kSecReturnData))
        keychainQuery.setObject(kSecMatchLimitOne, forKey: NSString(format: kSecMatchLimit))
        
        var keychainResult: AnyObject?
        
        guard SecItemCopyMatching(keychainQuery, &keychainResult) == 0 else {
            return nil
        }
        
        guard let data = keychainResult as? Data else {
            return nil
        }
        
        guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? Token else {
            return nil
        }
        
        return token
    }
    
    func removeFor(sessionId: String) {
        SecItemDelete(keychainParamsFor(sessionId: sessionId))
    }
    
    private func keychainParamsFor(sessionId: String) -> NSMutableDictionary {
        return [
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceKey,
            kSecAttrAccount: "SVK" + sessionId
            ] as NSMutableDictionary
    }
}
