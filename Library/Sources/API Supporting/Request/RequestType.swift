enum RequestType {
    case api(method: String, parameters: Parameters)
    case url(String)
    case upload(url: String, media: [Media], partType: PartType)
}

///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod: String {
    case GET, POST
}
