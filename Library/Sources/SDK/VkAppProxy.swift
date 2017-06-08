protocol VkAppProxy: class {
    func send(query: String) throws -> Bool
    func handle(url: URL, app: String?) -> String?
}

final class VkAppProxyImpl: VkAppProxy {
    
    private let baseUrl = "vkauthorize://authorize?"
    private let appId: String
    private let urlOpener: UrlOpener
    
    init(
        appId: String,
        urlOpener: UrlOpener
        ) {
        self.appId = appId
        self.urlOpener = urlOpener
    }
    
    func send(query: String) throws -> Bool {
        return try DispatchQueue.main.sync {
            guard let url = URL(string: baseUrl + query) else {
                throw SessionError.cantBuildUrlForVkApp
            }
            
            guard urlOpener.canOpenURL(url) else {
                return false
            }
            
            return urlOpener.openURL(url)
        }
    }
    
    func handle(url: URL, app: String?) -> String? {
        guard (app == "com.vk.vkclient" || app == "com.vk.vkhd") && url.scheme == "vk\(appId)" else {
            return nil
        }
        
        guard let fragment = url.fragment, fragment.contains("access_token") else {
            return nil
        }
        
        return fragment
    }
}
