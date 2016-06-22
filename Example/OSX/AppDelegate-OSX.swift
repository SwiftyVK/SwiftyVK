import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  
  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    _ = VKDelegateImpl(window_: window)
  }

  
  @IBAction func click(_ sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}

