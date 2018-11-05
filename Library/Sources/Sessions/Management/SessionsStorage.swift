import Foundation

protocol SessionsStorage {
    func save(sessions: [EncodedSession]) throws
    func restore() throws -> [EncodedSession]
}

final class SessionsStorageImpl: SessionsStorage {
    private let fileManager: VKFileManager
    private let gateQueue = DispatchQueue(label: "SwiftyVK.sessionStorageQueue")
    private let bundleName: String
    private let configName: String
    
    init(
        fileManager: VKFileManager,
        bundleName: String,
        configName: String
        ) {
        self.fileManager = fileManager
        self.bundleName = bundleName
        self.configName = configName
    }
    
    func save(sessions: [EncodedSession]) throws {
        try gateQueue.sync {
            let fileUrl = try configurationUrl()
            try createFileIfNotExists(at: fileUrl)
            let data = try PropertyListEncoder().encode(sessions)
            try data.write(to: fileUrl, options: .atomicWrite)
        }
    }
    
    func restore() throws -> [EncodedSession] {
        return try gateQueue.sync {
            let fileUrl = try configurationUrl()
            let rawData = try Data(contentsOf: fileUrl)
            let sessions = try PropertyListDecoder().decode([EncodedSession].self, from: rawData)
            return sessions
        }
    }
    
    func configurationUrl() throws -> URL {
		if configName.starts(with: "/") {
            return URL(fileURLWithPath: configName)
        }
        return try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            )
            .appendingPathComponent(bundleName)
            .appendingPathComponent("\(configName).plist")
    }
    
    func createFileIfNotExists(at url: URL) throws {
        guard !fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        _ = fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
    }
}
