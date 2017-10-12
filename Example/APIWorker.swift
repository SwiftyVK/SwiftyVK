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
            .onSuccess { print("SwiftyVK: captcha.force success \n \($0)") }
            .onError { print("SwiftyVK: captcha.force fail \n \($0)") }
            .send()
    }
    
    class func validation() {
        VK.API.Custom.method(name: "account.testValidation")
            .onSuccess { print("SwiftyVK: account.testValidation success \n \($0)") }
            .onError { print("SwiftyVK: account.testValidation fail \n \($0)") }
            .send()
    }
    
    class func usersGet() {
        VK.API.Users.get([Parameter.userId : "1"])
            .onSuccess { print("SwiftyVK: users.get success \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    class func friendsGet() {
        VK.API.Friends.get([.count : "1", .fields : "city,domain"])
            .onSuccess { print("SwiftyVK: friends.get success \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    class func uploadPhoto() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "testImage", ofType: "jpg")!))
        let media = Media.image(data: data, type: .jpg)
        
        VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178"))
            .onSuccess { print("SwiftyVK: friendsGet success \n \($0)") }
            .onError { print("SwiftyVK: friendsGet fail \n \($0)")}
            .onProgress { print("\($0) \($1) of \($2)")}
            .send()
    }
}
