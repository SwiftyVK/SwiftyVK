@testable import SwiftyVK

final class SessionsStorageMock: SessionsStorage {
    
    var onSave: (([EncodedSession]) throws -> ())?
    var onRestore: (() throws -> [EncodedSession])?
    
    func save(sessions: [EncodedSession]) throws {
        return try onSave?(sessions) ?? ()
    }
    
    func restore() throws -> [EncodedSession] {
        return try onRestore?() ?? []
    }
    
}
