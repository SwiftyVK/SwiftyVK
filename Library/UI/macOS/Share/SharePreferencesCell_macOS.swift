import Cocoa

final class SharePreferencesCellMacOS: NSView {
    @IBOutlet private weak var nameLabel: NSTextField?
    @IBOutlet private weak var stateSwitcher: JSSwitch?
    
    private var preference: ShareContextPreference?
    
    override func viewWillDraw() {
        super.viewWillDraw()
        nameLabel?.stringValue = preference?.name ?? ""
        stateSwitcher?.on = preference?.active ?? false
    }
    
    func set(preference: ShareContextPreference) {
        self.preference = preference
        nameLabel?.stringValue = preference.name
        stateSwitcher?.on = preference.active
    }
    
    @IBAction func stateChanged(_ sender: JSSwitch) {
        preference?.active = sender.on
    }
}
