public struct ShareContext: Equatable {
    
    private let text: String?
    private let images: [Data]
    private let link: ShareDialogLink?
    
    public init(
        text: String? = nil,
        images: [Data] = [],
        link: ShareDialogLink? = nil
        ) {
        self.text = text
        self.images = images
        self.link = link
    }
    
    public static func == (lhs: ShareContext, rhs: ShareContext) -> Bool {
        return lhs.text == rhs.text && lhs.images == rhs.images && lhs.link == rhs.link
    }
}

public struct ShareDialogLink: Equatable {
    
    private let title: String
    private let url: URL
    
    public init(
        title: String,
        url: URL
        ) {
        self.title = title
        self.url = url
    }
    
    public static func == (lhs: ShareDialogLink, rhs: ShareDialogLink) -> Bool {
        return lhs.title == rhs.title && lhs.url == rhs.url
    }
}
