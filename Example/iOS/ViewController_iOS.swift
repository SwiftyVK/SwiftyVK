import UIKit
import SwiftyVK

final class ViewController: UIViewController {

  @IBAction func buttonDown(_ sender: AnyObject) {
    APIWorker.action(sender.tag)
  }
}

