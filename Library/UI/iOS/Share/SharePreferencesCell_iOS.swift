import UIKit

final class SharePreferencesCellIOS: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var stateSwitcher: UISwitch?
    
    private var preference: ShareContextPreference?
    
    func set(preference: ShareContextPreference) {
        self.preference = preference
        nameLabel?.text = preference.name
        stateSwitcher?.isOn = preference.active
    }
    
    @IBAction func onStateChange(_ sender: UISwitch) {
        preference?.active = sender.isOn
    }
}
