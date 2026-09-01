import Foundation
import SwiftyVK


@MainActor
final class APIWorker {
    
    class func action(_ tag: Int) {
        Swift.Task {
            await performAction(tag)
        }
    }

    private class func performAction(_ tag: Int) async {
        do {
            switch tag {
            case 1:
                try await authorize()
            case 2:
                logout()
            case 3:
                try await captcha()
            case 4:
                try await usersGet()
            case 5:
                try await friendsGet()
            case 6:
                try await uploadPhoto()
            case 7:
                try await validation()
            case 8:
                try await share()
            default:
                print("Unrecognized action!")
            }
        } catch {
            print("SwiftyVK: action \(tag) failed with \n \(error)")
        }
    }

    private class func authorize() async throws {
        let info = try await VK.sessions.default.logIn()
        print("SwiftyVK: success authorize with", info)
    }
    
    private class func logout() {
        VK.sessions.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
    private class func captcha() async throws {
        let response = try await VK.API.Custom.method(name: "captcha.force").send()
        print("SwiftyVK: captcha.force succeeded with \n \(JSON(response))")
    }
    
    private class func validation() async throws {
        let response = try await VK.API.Custom.method(name: "account.testValidation").send()
        print("SwiftyVK: account.testValidation succeeded with \n \(JSON(response))")
    }
    
    private class func usersGet() async throws {
        let response = try await VK.API.Users.get(.empty)
            .configure(with: Config(httpMethod: .POST))
            .send()
        print("SwiftyVK: users.get succeeded with \n \(JSON(response))")
    }
    
    private class func friendsGet() async throws {
        let response = try await VK.API.Friends.get(.empty).send()
        print("SwiftyVK: friends.get succeeded with \n \(JSON(response))")
    }
    
    private class func uploadPhoto() async throws {
        guard
            let pathToImage = Bundle.main.path(forResource: "testImage", ofType: "png"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: pathToImage))
            else {
                print("Can not find testImage.png")
                return
        }
        
        let media = Media.image(data: data, type: .png)
        
        for try await event in VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178")).sendWithProgress() {
            switch event {
            case let .progress(progress):
                print(progress)
            case let .response(response):
                print("SwiftyVK: upload succeeded with \n \(JSON(response))")
            }
        }
    }
    
    private class func share() async throws {
        guard
            let pathToImage = Bundle.main.path(forResource: "testImage", ofType: "png"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: pathToImage)),
            let link = URL(string: "https://en.wikipedia.org/wiki/Hyperspace")
            else {
                print("Can not find testImage.png")
                return
        }
        
        let context = ShareContext(
                text: "This post made with #SwiftyVK 🖖🏽",
                images: [
                    ShareImage(data: data, type: .jpg),
                    ShareImage(data: data, type: .jpg),
                    ShareImage(data: data, type: .jpg),
                ],
                link: ShareLink(
                    title: "Follow the white rabbit",
                    url: link
                )
        )

        let response = try await VK.sessions.default.share(context)
        print("SwiftyVK: successfully shared with \n \(JSON(response))")
    }
}
