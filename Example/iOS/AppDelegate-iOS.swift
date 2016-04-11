import UIKit
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VKDelegate {
  
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    VK.start(appID: APIWorker.appID, delegate: self)
    return true
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    VK.processURL(url, options: options)
    return true
  }
  
  func vkAutorizationFailed(error: VK.Error) {
    print("Autorization failed with error: \n\(error)")
  }
  
  func vkWillAutorize() -> [VK.Scope] {
    return APIWorker.scope
  }
  
  func vkDidAutorize(parameters: Dictionary<String, String>) {
  }
  
  func vkDidUnautorize() {}
  
  func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
    return (true, "")
  }
  
  func vkWillPresentView() -> UIViewController {
    return self.window!.rootViewController!
  }
  
  @IBAction func buttonDown(sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}