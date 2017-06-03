import Cocoa
import SwiftyVK

class ViewController: NSViewController {
    
    @IBAction func buttonDown(_ sender: AnyObject) {
        APIWorker.action(sender.tag)
    }
}
