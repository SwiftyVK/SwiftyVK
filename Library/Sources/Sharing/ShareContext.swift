public struct ShareContext: Equatable {
    
    var text: String?
    let images: [String: Data]
    let link: ShareLink?
    
    public init(
        text: String? = nil,
        images: [Data] = [],
        link: ShareLink? = nil
        ) {
        self.text = text
        self.images = images.reduce(into: [String: Data]()) { $0[String.random(5)] = $1 }
        self.link = link
    }
    
    public static func == (lhs: ShareContext, rhs: ShareContext) -> Bool {
        return lhs.text == rhs.text && lhs.images == rhs.images && lhs.link == rhs.link
    }
}

public struct ShareLink: Equatable {
    
    private let title: String
    private let url: URL
    
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
