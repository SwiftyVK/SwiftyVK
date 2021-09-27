import Foundation

protocol VKAppProxy: AnyObject {
    @discardableResult
    func send(query: String) -> Bool
    func canSend(query: String) -> Bool
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
    
    deinit {
        appLifecycleProvider.unsubscribe(self)
    }
    
    @discardableResult
    func send(query: String) -> Bool {
        guard openVkApp(query: query) else {
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

    func canSend(query: String) -> Bool {
        guard let url = vkAppURL(using: query) else {
            return false
        }

        guard  urlOpener.canOpenURL(url) else {
            return false
        }

        return true
    }

    private func vkAppURL(using query: String) -> URL? {
        guard let url = URL(string: baseUrl + query) else {
            return nil
        }

        guard  urlOpener.canOpenURL(url) else {
            return nil
        }

        return url
    }

    private func openVkApp(query: String) -> Bool {
        return DispatchQueue.anywayOnMain {
            guard let url = vkAppURL(using: query) else {
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
        let isAppCorrect = (app == "com.vk.vkclient" || app == "com.vk.vkhd" || app == nil)
        let isSchemeCorrect = url.scheme == "vk\(appId)"
        let isHostCorrect = url.host == "authorize"
        
        guard isAppCorrect && isSchemeCorrect && isHostCorrect else {
            return nil
        }
        
        guard let fragment = url.fragment, fragment.contains("access_token") else {
            return nil
        }
        
        return fragment
    }
}
