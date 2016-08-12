import UIKit
import SwiftyVK



class ViewController: UIViewController {

  @IBAction func buttonDown(_ sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}

