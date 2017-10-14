protocol MultipartBodyBuilder {
    var boundary: String { get }
    
    func makeBody(from media: [Media], partType: PartType) -> Data
}

final class MultipartBodyBuilderImpl: MultipartBodyBuilder {
    
    let boundary = "<<@=!=!=!=SWIFTY_VK_BOUNDARY=!=!=!=@>>"
    
    func makeBody(from media: [Media], partType: PartType) -> Data {
        var body = Data()
        
        for (index, file) in media.enumerated() {
            let name: String
            
            switch partType {
            case .photo:
                name = "photo"
            case .video:
                name = "video_file"
            case .file:
                name = "file"
            case .indexedFile:
                name = "file\(index)"
            }
            
            if let data = (""
                + "\r\n"
                + "--\(boundary)\r\n"
                + "Content-Disposition: form-data; name=\"\(name)\"; filename=\"file.\(file.type)\"\r\n"
                + "Content-Type: document/other\r\n"
                + "\r\n"
                )
                .data(using: .utf8, allowLossyConversion: false) {
                body.append(data)
            }
            
            body.append(file.data as Data)
        }
        
        if !media.isEmpty, let data = "\r\n--\(boundary)--\r".data(using: .utf8, allowLossyConversion: false) {
            body.append(data)
        }
        
        return body
    }
}

enum PartType {
    case photo
    case video
    case file
    case indexedFile
}
