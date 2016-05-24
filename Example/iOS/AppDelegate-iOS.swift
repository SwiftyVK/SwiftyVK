import UIKit
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    _ = VKDelegateImpl(window_: window!)
    return true
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    VK.processURL(url, options: options)
    return true
  }

  
  @IBAction func buttonDown(sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}