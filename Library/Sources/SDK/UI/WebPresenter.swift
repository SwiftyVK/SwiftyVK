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
    private var error: ErrorAuth?
    private weak static var currentController: WebController?
    
    
    
    class func start(withUrl url: String) -> ErrorAuth? {
        
        let presenter = WebPresenter()
        
        guard let controller = WebController.create(withDelegate: presenter) else {
            return ErrorAuth.nilParentView
        }
        
        currentController = controller
        presenter.controller = controller
        presenter.controller.load(url: url)
        presenter.semaphore.wait()
        return presenter.error
    }
    
    
    
    class func cancel() {
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
            error = ErrorAuth.deniedFromUser
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
    
    
    
    func handleError(_ error: ErrorAuth) {
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
