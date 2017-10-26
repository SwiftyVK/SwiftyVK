import Foundation
import SwiftyVK


final class APIWorker {
    
    class func action(_ tag: Int) {
        switch tag {
        case 1:
            authorize()
        case 2:
            logout()
        case 3:
            captcha()
        case 4:
            usersGet()
        case 5:
            friendsGet()
        case 6:
            uploadPhoto()
        case 7:
            validation()
        case 8:
            share()
        default:
            print("Unrecognized action!")
        }
    }
    
    class func authorize() {
        VK.sessions?.default.logIn(
            onSuccess: { info in
                print("SwiftyVK: success authorize with", info)
            },
            onError: { error in
                print("SwiftyVK: authorize failed with", error)
            }
        )
    }
    
    class func logout() {
        VK.sessions?.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
    class func captcha() {
        VK.API.Custom.method(name: "captcha.force")
            .onSuccess { print("SwiftyVK: captcha.force successed with \n \($0)") }
            .onError { print("SwiftyVK: captcha.force failed with \n \($0)") }
            .send()
    }
    
    class func validation() {
        VK.API.Custom.method(name: "account.testValidation")
            .onSuccess { print("SwiftyVK: account.testValidation successed with \n \($0)") }
            .onError { print("SwiftyVK: account.testValidation failed with \n \($0)") }
            .send()
    }
    
    class func usersGet() {
        VK.API.Users.get(.empty)
            .configure(with: Config.init(httpMethod: .POST))
            .onSuccess { print("SwiftyVK: users.get successed with \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    class func friendsGet() {
        VK.API.Friends.get(.empty)
            .onSuccess { print("SwiftyVK: friends.get successed with \n \($0)") }
            .onError { print("SwiftyVK: friends.get failed with \n \($0)") }
            .send()
    }
    
    class func uploadPhoto() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "testImage", ofType: "jpg")!))
        let media = Media.image(data: data, type: .jpg)
        
        VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178"))
            .onSuccess { print("SwiftyVK: friendsGet successed with \n \($0)") }
            .onError { print("SwiftyVK: friendsGet failed with \n \($0)")}
            .onProgress { print($0) }
            .send()
    }
    
    class func share() {
        VK.sessions?.default.share(ShareContext())
    }
}
