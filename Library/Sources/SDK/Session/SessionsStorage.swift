import Foundation

protocol SessionsStorage {
    func save(sessions: [EncodedSession]) throws
    func restore() throws -> [EncodedSession]
}

final class SessionsStorageImpl: SessionsStorage {
    
    private let configName: String
    
    init(configName: String) {
        self.configName = configName
    }
    func save(sessions: [EncodedSession]) throws {
        let fileUrl = try configurationUrl()
        let data = try PropertyListEncoder().encode(sessions)
        try data.write(to: fileUrl, options: .atomicWrite)
    }
    
    func restore() throws -> [EncodedSession] {
        let fileUrl = try configurationUrl()
        let rawData = try Data(contentsOf: fileUrl)
        let sessions = try PropertyListDecoder().decode([EncodedSession].self, from: rawData)
        return sessions
    }
    
    func configurationUrl() throws -> URL {
        
        return try FileManager.default.url(
            for: FileManager.SearchPathDirectory.applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            )
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
            .appendingPathComponent(configName + ".plist")
    }
}
