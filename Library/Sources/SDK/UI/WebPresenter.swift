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
private let authorizeUrl2 = "https://oauth.vk.com/oauth/authorize?"



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



    func handle(response: String) {

        if response.contains("access_token=") {
            controller.hide()
            _ = Token(fromResponse: response)
            error = nil
        }
        else if response.contains("success=1") {
            controller.hide()
            error = nil
        }
        else if response.contains("access_denied") || response.contains("cancel=1") {
            controller.hide()
            error = AuthError.deniedFromUser
        }
        else if response.contains("fail=1") {
            controller.hide()
            error = .failedAuthorization
        }
        else if response.contains(authorizeUrl) ||
            response.contains(authorizeUrl2) ||
            response.contains("act=security_check") ||
            response.contains("api_validation_test") ||
            response.contains("https://m.vk.com/login?") {
            controller.expand()
        }
        else {
            controller.goBack()
        }
    }



    func handle(error: AuthError) {
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
