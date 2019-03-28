import Foundation

class KeychainProvider<EntityType> {
    
    let serviceKey: String
    
    init(serviceKey: String) {
        self.serviceKey = serviceKey
    }
    
    func save(_ entity: EntityType, for sessionId: String) throws {
        let keychainQuery = keychainParamsFor(sessionId: sessionId)
        
        let data: Data
        
        if #available(iOS 11.0, OSX 10.13, *) {
            data = try NSKeyedArchiver.archivedData(withRootObject: entity, requiringSecureCoding: false)
        }
        else if #available(iOS 2.0, OSX 10.11, *) {
            data = NSKeyedArchiver.archivedData(withRootObject: entity)
        }
        else {  
            // Because Xcode 10 has a bug - http://openradar.appspot.com/49262697
            // swiftlint:disable next compiler_protocol_init
            let selector = Selector(stringLiteral: "archivedDataWithRootObject:")
            // swiftlint:disable next force_cast force_unwrapping
            data = NSKeyedArchiver.perform(selector, with: entity)!.takeRetainedValue() as! Data
        }

        keychainQuery.setObject(data, forKey: NSString(format: kSecValueData))
        
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
