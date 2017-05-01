protocol BodyBuilder {
    var boundary: String {get}
    func makeBody(from media: [Media]) -> Data
}

final class BodyBuilderImpl: BodyBuilder {
    
    let boundary = "(======SwiftyVK======)"
    
    func makeBody(from media: [Media]) -> Data {
        var body = Data()
        
        for (index, file) in media.enumerated() {
            let name: String
            
            switch file {
            case .video:
                name = "video_file"
            case .audio, .document:
                name = "file"
            case .image:
                name = "file\(index)"
            }
            
            if let data = ("\r\n--\(boundary)\r\nContent-Disposition: form-data; name="
                + "\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n")
                .data(using: .utf8, allowLossyConversion: false) {
                body.append(data)
            }
            
            body.append(file.data as Data)
        }
        
        if let data = "\r\n--\(boundary)--\r".data(using: .utf8, allowLossyConversion: false) {
            body.append(data)
        }
        
        return body
    }
}
