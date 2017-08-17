// swiftlint:disable cyclomatic_complexity
public typealias Scopes = Set<VK.Scope>

extension VK {
    ///Application scope
    public enum Scope: Int {
        case notify = 1
        case friends = 2
        case photos = 4
        case audio = 8
        case video = 16
        case docs = 131072
        case notes = 2048
        case pages = 128
        case status = 1024
        case offers = 32
        case questions = 64
        case wall = 8192
        case groups = 262144
        case messages = 4096
        case email = 4194304
        case notifications = 524288
        case stats = 1048576
        case ads = 32768
        case offline = 65536
        case market = 134217728

        public var description: String {
            return Mirror(reflecting: self).children.first?.label.flatMap { $0 } ?? String()
        }
        
        public static func create(from permissions: Int) -> Set<Scope> {
            var result = Set<Scope>()
            
            if (permissions & 1) == 1 { result.insert(.notify) }
            if (permissions & 2) == 2 { result.insert(.friends) }
            if (permissions & 4) == 4 { result.insert(.photos) }
            if (permissions & 8) == 8 { result.insert(.audio) }
            if (permissions & 16) == 16 { result.insert(.video) }
            if (permissions & 131072) == 131072 { result.insert(.docs) }
            if (permissions & 2048) == 2048 { result.insert(.notes) }
            if (permissions & 128) == 128 { result.insert(.pages) }
            if (permissions & 1024) == 1024 { result.insert(.status) }
            if (permissions & 32) == 32 { result.insert(.offers) }
            if (permissions & 64) == 64 { result.insert(.questions) }
            if (permissions & 8192) == 8192 { result.insert(.wall) }
            if (permissions & 262144) == 262144 { result.insert(.groups) }
            if (permissions & 4096) == 4096 { result.insert(.messages) }
            if (permissions & 4194304) == 4194304 { result.insert(.email) }
            if (permissions & 524288) == 524288 { result.insert(.notifications) }
            if (permissions & 1048576) == 1048576 { result.insert(.stats) }
            if (permissions & 32768) == 32768 { result.insert(.ads) }
            if (permissions & 65536) == 65536 { result.insert(.offline) }
            if (permissions & 134217728) == 134217728 { result.insert(.market) }
            
            return result
        }
        
        public static func create(from permissions: String) -> Set<Scope> {
            var result = Set<Scope>()
            
            if permissions.contains("notify") { result.insert(.notify) }
            if permissions.contains("friends") { result.insert(.friends) }
            if permissions.contains("photos") { result.insert(.photos) }
            if permissions.contains("audio") { result.insert(.audio) }
            if permissions.contains("video") { result.insert(.video) }
            if permissions.contains("docs") { result.insert(.docs) }
            if permissions.contains("notes") { result.insert(.notes) }
            if permissions.contains("pages") { result.insert(.pages) }
            if permissions.contains("status") { result.insert(.status) }
            if permissions.contains("questions") { result.insert(.questions) }
            if permissions.contains("wall") { result.insert(.wall) }
            if permissions.contains("groups") { result.insert(.groups) }
            if permissions.contains("messages") { result.insert(.messages) }
            if permissions.contains("email") { result.insert(.email) }
            if permissions.contains("notifications") { result.insert(.notifications) }
            if permissions.contains("stats") { result.insert(.stats) }
            if permissions.contains("ads") { result.insert(.ads) }
            if permissions.contains("offers") { result.insert(.offers) }
            if permissions.contains("offline") { result.insert(.offline) }
            if permissions.contains("market") { result.insert(.market) }
            
            return result
        }
    }
}

extension Set where Element == VK.Scope {
    
    public func toInt() -> Int {
        return self.reduce(0) { $0 + $1.rawValue }
    }
    
    public func toString() -> String {
        return self.reduce("") {
            $0 + (Mirror(reflecting: $1).children.first?.label.flatMap { $0 + "," } ?? String())
        }
    }
}
