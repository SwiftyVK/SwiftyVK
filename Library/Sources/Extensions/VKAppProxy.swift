import Foundation

protocol VKAppProxy: class {
    @discardableResult
    func send(query: String) throws -> Bool
    func handle(url: URL, app: String?) -> String?
}

final class VKAppProxyImpl: VKAppProxy {
    
    private let baseUrl = "vkauthorize://authorize?"
    private let appId: String
    private let urlOpener: URLOpener
    private let appLifecycleProvider: AppLifecycleProvider
    
    init(
        appId: String,
        urlOpener: URLOpener,
        appLifecycleProvider: AppLifecycleProvider
        ) {
        self.appId = appId
        self.urlOpener = urlOpener
        self.appLifecycleProvider = appLifecycleProvider
    }
    
    @discardableResult
    func send(query: String) throws -> Bool {
        guard try openVkApp(query: query) else {
            return false
        }
        
        guard wait(to: .inactive, timeout: .now() + 1) else {
            return false
        }
        
        guard wait(to: .active, timeout: .distantFuture) else {
            return false
        }
        
        return true
    }
    
    private func openVkApp(query: String) throws -> Bool {
        guard let url = URL(string: baseUrl + query) else {
            throw VKError.cantBuildVKAppUrl(baseUrl + query)
        }
        
        return DispatchQueue.anywayOnMain {
            guard  urlOpener.canOpenURL(url) else {
                return false
            }
            
            guard urlOpener.openURL(url) else {
                return false
            }
            
            return true
        }
    }
    
    private func wait(to appState: AppState, timeout: DispatchTime) -> Bool {
        defer { appLifecycleProvider.unsubscribe(self) }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        appLifecycleProvider.subscribe(self) {
            if $0 == appState { semaphore.signal() }
        }
        
        switch semaphore.wait(timeout: timeout) {
        case .success:
            return true
        case .timedOut:
            return false
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
