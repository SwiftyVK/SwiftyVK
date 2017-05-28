protocol VkAppProxy: class {
    func authorizeWith(query: String) throws -> Bool
    func recieveFrom(url: URL, app: String?) -> String?
}

final class VkAppProxyImpl: VkAppProxy {
    
    private let baseUrl = "vkauthorize://authorize?"
    private let urlOpener: UrlOpener
    
    init(urlOpener: UrlOpener) {
        self.urlOpener = urlOpener
    }
    
    func authorizeWith(query: String) throws -> Bool {
        guard try canOpenUrl() else {
            return false
        }
        
        guard let url = URL(string: baseUrl + query) else {
            throw SessionError.cantBuildUrlForVkApp
        }
        
        return urlOpener.openURL(url)
    }
    
    private func canOpenUrl() throws -> Bool {
        guard let url = VK.appId.flatMap({ URL(string: "vk\($0)://") }) else {
            throw SessionError.cantBuildUrlForVkApp
        }
        
        return urlOpener.canOpenURL(url)
    }
    
    func recieveFrom(url: URL, app: String?) -> String? {
        guard let appId = VK.appId else {
            return nil
        }
        
        guard (app == "com.vk.vkclient" || app == "com.vk.vkhd") && url.scheme == "vk\(appId)" else {
            return nil
        }
        
        guard let fragment = url.fragment, fragment.contains("access_token") else {
            return nil
        }
        
        return fragment
    }
}
