import Foundation



public struct Media : CustomStringConvertible {
  
  enum MediaType {
    case image
    case audio
    case video
    case document
  }
  
  
  
  public enum ImageType : String {
    case JPG
    case PNG
    case BMP
    case GIF
  }
  
  
  
  let data : NSData
  let mediaType : MediaType
  var imageType : ImageType = .JPG
  var documentType : String = "untitled"
  var type : String {
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
    get {
    return "VK.Media with type \(type)"
    }
  }
  
  
  public init(imageData: NSData, type: ImageType) {
    mediaType = .image
    imageType = type
    data = imageData
  }
  
  
  
  public init(audioData: NSData) {
    mediaType = .audio
    data = audioData
  }
  
  
  
  public init(videoData: NSData) {
    mediaType = .video
    data = videoData
  }
  
  
  
  public init(documentData: NSData, type: String) {
    mediaType = .document
    documentType = type
    data = documentData
  }
}
