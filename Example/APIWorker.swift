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
        VKAPI.Custom.method(name: "captcha.force")
            .onSuccess { print("SwiftyVK: captcha.force success \n \($0)") }
            .onError { print("SwiftyVK: captcha.force fail \n \($0)") }
            .send()
    }
    
    
    
    class func validation() {
        VKAPI.Custom.method(name: "account.testValidation")
            .onSuccess { print("SwiftyVK: account.testValidation success \n \($0)") }
            .onError { print("SwiftyVK: account.testValidation fail \n \($0)") }
            .send()
    }
    
    
    
    class func usersGet() {
        VKAPI.Users.get([VK.Arg.userId : "1"])
            .onSuccess { print("SwiftyVK: users.get success \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    
    
    class func friendsGet() {
        VKAPI.Friends.get([.count : "1", .fields : "city,domain"])
            .onSuccess { print("SwiftyVK: friends.get success \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .send()
    }
    
    
    
    class func uploadPhoto() {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "testImage", ofType: "jpg")!))
        let media = Media.image(data: data, type: .jpg)
        
        VKAPI.Upload.Photo.toAlbum([media], to: .user(id: "4680178"), albumId: "247425000")
            .onSuccess { print("SwiftyVK: friends.get success \n \($0)") }
            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
            .onProgress { print($0, $1, $2) }
            .send()
        
//        VKAPI.Upload.Photo.toWall.toUser(media, userId: "4680178").send(
//            onSuccess: {response in print("SwiftyVK: friendsGet success \n \(response)")},
//            onError: {error in print("SwiftyVK: friendsGet fail \n \(error)")},
//            onProgress: {done, total in print("send \(done) of \(total)")}
//        )
    }
}
