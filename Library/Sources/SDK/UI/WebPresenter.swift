//
//  WebProxy.swift
//  SwiftyVK
//
//  Created by Алексей Кудрявцев on 18.10.16.
//
//

import Foundation



internal let sheetQueue = DispatchQueue(label: "asdfghjkl")
private let authorizeUrl = "https://oauth.vk.com/authorize?"



internal final class WebPresenter {
    private let semaphore = DispatchSemaphore(value: 0)
    private var controller: WebController!
    private var fails = 0
    private var error: AuthError?
    private weak static var currentController: WebController?
    
    
    
    class func start(withUrl url: String) -> AuthError? {
        
        VK.Log.put("WebPresenter", "start")
        let presenter = WebPresenter()
        
        guard let controller = WebController.create(withDelegate: presenter) else {
            return AuthError.nilParentView
        }
        
        currentController = controller
        presenter.controller = controller
        presenter.controller.load(url: url)
        presenter.semaphore.wait()
        VK.Log.put("WebPresenter", "finish")

        return presenter.error
    }
    
    
    
    class func cancel() {
        VK.Log.put("WebPresenter", "cancel")
        currentController?.hide()
    }
    
    
    
    func handleResponse(_ urlString : String) {
        
        if urlString.contains("access_token=") {
            _ = Token(urlString: urlString)
            error = nil
            controller.hide()
        }
        else if urlString.contains("success=1") {
            error = nil
            controller.hide()
        }
        else if urlString.contains("access_denied") || urlString.contains("cancel=1") {
            error = AuthError.deniedFromUser
            controller.hide()
        }
        else if urlString.contains("fail=1") {
            error = .failedAuthorization
            controller.hide()
        }
        else if urlString.contains(authorizeUrl) ||
            urlString.contains("act=security_check") ||
            urlString.contains("api_validation_test") ||
            urlString.contains("https://m.vk.com/login?")
        {
            controller.expand()
        }
        else {
            controller.goBack()
        }
    }
    
    
    
    func handleError(_ error: AuthError) {
        VK.Log.put("WebPresenter", "handle \(error)")

        if fails <= 3 {
            self.error = error
            fails += 1
            controller.load(url: "")
        }
        else {
            controller.hide()
        }
    }
    
    
    
    func finish() {
        semaphore.signal()
    }
}
