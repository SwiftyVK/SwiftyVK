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
        VK.sessions?.default.logOut()
        print("SwiftyVK: LogOut")
        
        DispatchQueue.global().async {
            _ = try? VK.sessions?.default.logIn()
            print("SwiftyVK: authorize")
        }
    }
    
    
    
    class func logout() {
        VK.sessions?.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
    
    
    class func captcha() {
        VK.Api.Custom.method(name: "captcha.force").send(with: Callbacks(
            onSuccess: { response in print("SwiftyVK: captcha.force success \n \(response)") },
            onError: { error in print("SwiftyVK: captcha.force fail \n \(error)") }
            )
        )
    }
    
    
    
    class func validation() {
        VK.Api.Custom.method(name: "account.testValidation").send(with: Callbacks(
            onSuccess: {response in print("SwiftyVK: account.testValidation success \n \(response)")},
            onError: {error in print("SwiftyVK: account.testValidation fail \n \(error)")}
            )
        )
    }
    
    
    
    class func usersGet() {
        VK.Api.Users.get([VK.Arg.userId : "1"]).send(with: Callbacks(
            onSuccess: {response in print("SwiftyVK: users.get success \n \(response)")},
            onError: {error in print("SwiftyVK: users.get fail \n \(error)")}
            )
        )
    }
    
    
    
    class func friendsGet() {
        VK.Api.Friends.get([.count : "1", .fields : "city,domain"]).send(with: Callbacks(
            onSuccess: {response in print("SwiftyVK: friends.get success \n \(response)")},
            onError: {error in print("SwiftyVK: friends.get fail \n \(error)")}
            )
        )
    }
    
    
    
    class func uploadPhoto() {
//        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "testImage", ofType: "jpg")!))
//        let media = Media(imageData: data, type: .JPG)
//        VK.Api.Upload.Photo.toWall.toUser(media, userId: "4680178").send(
//            onSuccess: {response in print("SwiftyVK: friendsGet success \n \(response)")},
//            onError: {error in print("SwiftyVK: friendsGet fail \n \(error)")},
//            onProgress: {done, total in print("send \(done) of \(total)")}
//        )
    }
}
