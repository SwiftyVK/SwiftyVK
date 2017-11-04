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
            defer { shareWorker.clear(context: context) }
            controller?.showPlaceholder(true)
            context.preferences = try shareWorker.getPrefrences(in: session)
            shareWorker.upload(images: context.images, in: session)
            shareWorker.add(link: context.link)
            controller?.showPlaceholder(false)
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
                    if let data = try shareWorker.post(context: $0, in: session) {
                        result = .data(data)
                    }

                    controller?.close()
                } catch let caughtError {
                    if context.canShowError {
                        self?.showError(controller: controller, context: context)
                    }
                    
                    controller?.enablePostButton(true)
                    result = .error(caughtError.toVK())
                }
            },
            onDismiss: {
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
