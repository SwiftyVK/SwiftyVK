protocol SharePresenter {
    func share(_ context: ShareContext, in session: Session) throws -> Data
}

final class SharePresenterImpl: SharePresenter {
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: ShareControllerMaker
    private let shareWorker: ShareWorker
    private let reachability: VKReachability?
    
    init(
        uiSyncQueue: DispatchQueue,
        shareWorker: ShareWorker,
        controllerMaker: ShareControllerMaker,
        reachability: VKReachability?
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.shareWorker = shareWorker
        self.controllerMaker = controllerMaker
        self.reachability = reachability
    }
    
    func share(_ context: ShareContext, in session: Session) throws -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var context = context

        let controller = controllerMaker.shareController { [weak self] in
            self?.reachability?.stopWaitForReachable()
            semaphore.signal()
        }
        
        return try uiSyncQueue.sync {
            defer { shareWorker.clear(context: context) }
            controller.showPlaceholder(true)
            
            reachability?.waitForReachable { [weak controller] in
                controller?.showWaitForConnection()
            }
            
            context.preferences = try shareWorker.getPrefrences(in: session)
            shareWorker.upload(images: context.images, in: session)
            controller.showPlaceholder(false)
            
            return try present(
                controller: controller,
                context: context,
                semaphore: semaphore,
                in: session
            )
        }
    }
    
    private func present(
        controller: ShareController?,
        context: ShareContext,
        semaphore: DispatchSemaphore,
        in session: Session
        ) throws -> Data {
        var result: Result<Data, VKError>?

        controller?.share(
            context,
            onPost: { [weak self, weak controller, weak shareWorker] in
                controller?.enablePostButton(false)

                do {
                    guard let data = try shareWorker?.post(context: $0, in: session) else { return }
                    result = .data(data)
                    controller?.close()
                }
                catch let caughtError {
                    if context.canShowError {
                        self?.showError(controller: controller, context: context)
                    }
                    
                    controller?.enablePostButton(true)
                    result = .error(caughtError.toVK())
                }
            }
        )

        semaphore.wait()

        guard let data = try result?.unwrap() else {
            throw VKError.sharingWasDismissed
        }
        
        return data
    }
    
    private func showError(controller: ShareController?, context: ShareContext) {
        if context.canShowError {
            controller?.showError(
                title: Resources.localizedString(for: "Error"),
                message: Resources.localizedString(for: "SomethingWentWrong"),
                buttontext: Resources.localizedString(for: "Close")
            )
        }
    }
    
    deinit {
        print("DEINIT", type(of: self))
    }
}
