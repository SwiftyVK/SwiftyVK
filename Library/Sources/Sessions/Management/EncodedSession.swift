import Foundation

struct EncodedSession: Codable {
    let isDefault: Bool
    let id: String
    let config: SessionConfig
}
