import Cocoa

final class SharePreferencesControllerMacOS: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet private weak var tableView: NSTableView?
    
    var preferences = [ShareContextPreference]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView?.reloadData()
    }
    
    func set(preferences: [ShareContextPreference]) {
        self.preferences = preferences
        
        DispatchQueue.anywayOnMain {
            tableView?.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return preferences.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SharePreferencesCell"),
            owner: nil
        )
        
        if let shareView = view as? SharePreferencesCellMacOS {
            shareView.set(preference: preferences[row])
        }
        
        return view
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
}
