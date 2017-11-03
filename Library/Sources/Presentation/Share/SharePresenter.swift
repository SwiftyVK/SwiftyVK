protocol SharePresenter {
    func share(_ context: ShareContext, in session: Session) throws -> Data
}

final class SharePresenterImpl: SharePresenter {
    private let uiSyncQueue: DispatchQueue
    private let controllerMaker: ShareControllerMaker
    private let shareWorker: ShareWorker
    
    init(
        uiSyncQueue: DispatchQueue,
        shareWorker: ShareWorker,
        controllerMaker: ShareControllerMaker
        ) {
        self.uiSyncQueue = uiSyncQueue
        self.shareWorker = shareWorker
        self.controllerMaker = controllerMaker
    }
    
    
    func share(_ context: ShareContext, in session: Session) throws -> Data {
        let controller = controllerMaker.shareController()
        var context = context
        
        return try uiSyncQueue.sync {
            controller?.showPlaceholder(true)
            
            let preferences = try shareWorker.getUserInfo(in: session)
            
            controller?.showPlaceholder(false)
            shareWorker.add(link: context.link)
            shareWorker.upload(images: context.images, in: session)
            
            context.preferences.append(ShareContextPreference(key: "friendsOnly", name: "friendsOnly", active: false))
            
            if preferences.facebook {
                context.preferences.append(ShareContextPreference(key: "facebook", name: "facebook", active: preferences.facebook))
            }
            
            if preferences.twitter {
                context.preferences.append(ShareContextPreference(key: "twitter", name: "twitter", active: preferences.twitter))
            }
            
            if preferences.livejournal {
                context.preferences.append(ShareContextPreference(key: "livejournal", name: "livejournal", active: preferences.livejournal))
            }

            return try present(controller: controller, context: context, in: session)
        }
    }
    
    private func present(controller: ShareController?, context: ShareContext, in session: Session) throws -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, VKError>?

        controller?.share(
            context,
            onPost: { [weak self, weak controller, shareWorker] in
                controller?.enablePostButton(false)

                do {
                    result = try .data(shareWorker.post(context: $0, in: session))
                    controller?.close()
                } catch let caughtError {
                    controller?.enablePostButton(true)
                    self?.showError(controller: controller, context: context)
                    result = .error(caughtError.toVK())
                }
            },
            onDismiss: { [shareWorker] in
                shareWorker.clear(context: context)
                semaphore.signal()
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
                title: NSLocalizedString("Error", bundle: Resources.bundle, comment: ""),
                message: NSLocalizedString("Something went wrong", bundle: Resources.bundle, comment: ""),
                buttontext: NSLocalizedString("Close", bundle: Resources.bundle, comment: "")
            )
        }
    }
    
    deinit {
        print("DEINIT", type(of: self))
    }
}
