protocol VKReachability {
    var isReachable: Bool { get }

    func startNotifier() throws
}

extension Reachability: VKReachability {}
