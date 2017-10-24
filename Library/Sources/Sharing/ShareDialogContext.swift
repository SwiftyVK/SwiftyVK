public struct ShareDialogContext {
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
}

public struct ShareDialogLink {
    private let title: String
    private let url: URL
    
    public init(
        title: String,
        url: URL
        ) {
        self.title = title
        self.url = url
    }
}
