class KeychainProvider<EntityType> {
    
    let serviceKey: String
    
    init(serviceKey: String) {
        self.serviceKey = serviceKey
    }
    
    func save(_ entity: EntityType, for sessionId: String) throws {
        let keychainQuery = keychainParamsFor(sessionId: sessionId)
        
        keychainQuery.setObject(
            NSKeyedArchiver.archivedData(withRootObject: entity),
            forKey: NSString(format: kSecValueData)
        )
        
        removeFor(sessionId: sessionId)
        
        let keychainCode = SecItemAdd(keychainQuery, nil)
        
        guard keychainCode == 0 else {
            throw VKError.cantSaveToKeychain(keychainCode)
        }
    }
    
    func getFor(sessionId: String) -> EntityType? {
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
        
        guard let entity = NSKeyedUnarchiver.unarchiveObject(with: data) as? EntityType else {
            return nil
        }
        
        return entity
    }
    
    func removeFor(sessionId: String) {
        SecItemDelete(keychainParamsFor(sessionId: sessionId))
    }
    
    private func keychainParamsFor(sessionId: String) -> NSMutableDictionary {
        return [
            kSecAttrAccessible: kSecAttrAccessibleAlways,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceKey,
            kSecAttrAccount: "SVK" + sessionId
            ] as NSMutableDictionary
    }
}
