protocol VKReachability {
    func startNotifier() throws
    
    var isReachable: Bool { get }
}

extension Reachability: VKReachability {}
