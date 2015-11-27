import Cocoa
import SwiftyVK

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, VKDelegate {

  
  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    VK.start(appID: APIWorker.appID, delegate: self)
  }


  func vkAutorizationFailed(error: VK.Error) {
    print("Autorization failed with error: \n\(error)")
  }

  func vkWillAutorize() -> [VK.Scope] {
    return APIWorker.scope
  }
  
  func vkDidAutorize() {}
  
  func vkDidUnautorize() {}
  
  func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
    return (true, "")
  }
  
  func vkWillPresentWindow() -> (isSheet: Bool, inWindow: NSWindow?) {
    return (true, window!)
  }
  
  
  @IBAction func click(sender: AnyObject) {
    APIWorker.action(sender.tag())
  }
}

