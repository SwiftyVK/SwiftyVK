import Foundation

public enum Media: CustomStringConvertible {
    case image(data: Data, type: ImageType)
    case audio(data: Data)
    case video(data: Data)
    case document(data: Data, type: String)
    
    var type: String {
        switch self {
        case .image(_, let type):
            return type.rawValue
        case .document(_, let type):
            return type
        case .audio:
            return "mp3"
        case .video:
            return "video"
        }
    }
    
    var data: Data {
        switch self {
        case .image(let data, _):
            return data
        case .document(let data, _):
            return data
        case .audio(let data):
            return data
        case .video(let data):
            return data
        }
    }
    
    public var description: String {
        return "Media with type \(type)"
    }
}

public enum ImageType: String {
    case jpg
    case png
    case bmp
    case gif
}
