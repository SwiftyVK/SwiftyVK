import UIKit
import SwiftyVK

class ViewController: UIViewController {

  @IBAction func buttonDown(sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}

