protocol VKAppProxy: class {
    func send(query: String) throws -> Bool
    func handle(url: URL, app: String?) -> String?
}

final class VKAppProxyImpl: VKAppProxy {
    
    private let baseUrl = "vkauthorize://authorize?"
    private let appId: String
    private let urlOpener: URLOpener
    
    init(
        appId: String,
        urlOpener: URLOpener
        ) {
        self.appId = appId
        self.urlOpener = urlOpener
    }
    
    func send(query: String) throws -> Bool {
        
        return try DispatchQueue.safelyOnMain {
            guard let url = URL(string: baseUrl + query) else {
                throw VKError.cantBuildVKAppUrl(baseUrl + query)
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
