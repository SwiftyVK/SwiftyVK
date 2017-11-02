public struct ShareContext: Equatable {
    
    var message: String?
    let images: [ShareImage]
    let link: ShareLink?
    let canShowError: Bool
    var preferences = [ShareContextPreference]()
    
    var hasAttachments: Bool {
        return images.isEmpty || link != nil
    }
    
    public init(
        text: String? = nil,
        images: [ShareImage] = [],
        link: ShareLink? = nil,
        canShowError: Bool = true
        ) {
        self.message = text
        self.images = images
        self.link = link
        self.canShowError = canShowError
    }
    
    public static func == (lhs: ShareContext, rhs: ShareContext) -> Bool {
        return lhs.message == rhs.message && lhs.images == rhs.images && lhs.link == rhs.link
    }
}

public struct ShareLink: Equatable {
    
    let title: String
    let url: URL
    
    public init(
        title: String,
        url: URL
        ) {
        self.title = title
        self.url = url
    }
    
    public static func == (lhs: ShareLink, rhs: ShareLink) -> Bool {
        return lhs.title == rhs.title && lhs.url == rhs.url
    }
}

public final class ShareImage: Equatable {
    let data: Data
    let type: ImageType
    
    var state: ShareImageUploadState? {
        didSet {
            switch state {
            case .uploaded?:
                onUpload?()
            case .failed?:
                onFail?()
            default:
                break
            }
        }
    }
    
    private var onUpload: (() -> ())?
    private var onFail: (() -> ())?
    
    public init(data: Data, type: ImageType) {
        self.data = data
        self.type = type
    }
    
    func setOnUpload(_ onUpload: @escaping (() -> ())) {
        self.onUpload = onUpload
    }
    
    func setOnFail(_ onFail: @escaping (() -> ())) {
        self.onFail = onFail
    }
    
    public static func == (lhs: ShareImage, rhs: ShareImage) -> Bool {
        return lhs.data == rhs.data
    }
}

enum ShareImageUploadState: Equatable {
    case uploaded
    case failed
}

final class ShareContextPreference {
    let name: String
    var active: Bool
    
    init(name: String, active: Bool) {
        self.name = name
        self.active = active
    }
}
