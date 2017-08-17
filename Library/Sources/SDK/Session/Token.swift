protocol Token: class, NSCoding {
    func get() -> String?
    var info: [String : String] { get }
}

class TokenImpl: NSObject, Token {
    
    private let token: String
    private let expires: Expires
    let info: [String: String]
    
    var isValid: Bool {
       return !expires.isExpired
    }
    
    init(
        token: String,
        expires: TimeInterval,
        info: [String : String]
        ) {
        self.token = token
        self.expires = Expires(expires: expires)
        self.info = info
    }
    
    func get() -> String? {
        return isValid ? token : nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token")
        aCoder.encode(info, forKey: "info")
        
        switch expires {
        case .never:
            aCoder.encode("never", forKey: "expireCase")
        case.during(let created, let expires):
            aCoder.encode("during", forKey: "expireCase")
            aCoder.encode(created, forKey: "crated")
            aCoder.encode(expires, forKey: "expires")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let token = aDecoder.decodeObject(forKey: "token") as? String,
            let info = aDecoder.decodeObject(forKey: "info") as? [String : String],
            let expireCase = aDecoder.decodeObject(forKey: "expireCase") as? String else {
                return nil
        }
        
        self.token = token
        self.info = info
        
        switch expireCase {
        case "never":
            self.expires = .never
        case "during":
            let created = aDecoder.decodeDouble(forKey: "crated")
            let expires = aDecoder.decodeDouble(forKey: "expires")
            
            self.expires = .during(created: created, expires: expires)
        default:
            return nil
        }
    }
}

private enum Expires {
    case never
    case during(created: TimeInterval, expires: TimeInterval)
    
    init(expires: TimeInterval) {
        if expires == 0 {
            self = .never
        }
        else {
            self = .during(created: Date().timeIntervalSince1970, expires: expires)
        }
    }

    var isExpired: Bool {
        switch self {
        case .never:
            return false
        case .during(let created, let expires):
            let deadline = Date(timeIntervalSince1970: created).addingTimeInterval(expires)
            return Date() > deadline
        }
    }
}
