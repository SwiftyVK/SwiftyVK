#if os(iOS)
import UIKit

final class SharePreferencesControllerIOS:
UIViewController, SharePreferencesController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView?

    var preferences = [ShareContextPreference]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    func set(preferences: [ShareContextPreference]) {
        self.preferences = preferences
        
        DispatchQueue.anywayOnMain {
            tableView?.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        preferences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "SharePreferencesCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let preferenceCell = cell as? SharePreferencesCellIOS else {
            return
        }
        
        preferenceCell.set(preference: preferences[indexPath.row])
    }
}

#endif
