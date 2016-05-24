import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  
  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    _ = VKDelegateImpl(window_: window)
  }

  
  @IBAction func click(sender: AnyObject) {
    APIWorker.action(sender.tag())
  }
}

