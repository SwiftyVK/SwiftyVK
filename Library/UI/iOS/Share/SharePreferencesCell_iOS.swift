#if os(iOS)
import UIKit

final class SharePreferencesCellIOS: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var stateSwitcher: UISwitch?
    
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

#endif
