import Foundation

public struct Media: CustomStringConvertible {
    
    enum MediaType {
        case image
        case audio
        case video
        case document
    }
    
    public enum ImageType: String {
        case JPG
        case PNG
        case BMP
        case GIF
    }
    
    let data: Data
    let mediaType: MediaType
    var imageType: ImageType = .JPG
    var documentType: String = "untitled"
    var type: String {
        switch mediaType {
        case .image:
            return imageType.rawValue
        case .document:
            return documentType
        case .audio:
            return "mp3"
        case .video:
            return "video"
        }
    }
    
    public var description: String {
        return "Media with type \(type)"
    }
    
    public init(imageData: Data, type: ImageType) {
        mediaType = .image
        imageType = type
        data = imageData
    }
    
    public init(audioData: Data) {
        mediaType = .audio
        data = audioData
    }
    
    public init(videoData: Data) {
        mediaType = .video
        data = videoData
    }
    
    public init(documentData: Data, type: String) {
        mediaType = .document
        documentType = type
        data = documentData
    }
}
