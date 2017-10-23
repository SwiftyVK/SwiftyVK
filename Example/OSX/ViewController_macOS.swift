import Cocoa
import SwiftyVK

final class ViewController: NSViewController {
    
    @IBAction func buttonDown(_ sender: AnyObject) {
        APIWorker.action(sender.tag)
    }
}
