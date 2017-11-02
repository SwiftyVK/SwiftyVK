protocol SharePresenter {
    func share(
        _ context: ShareContext,
        in session: Session,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
    )
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
    
    
    func share(
        _ context: ShareContext,
        in session: Session,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
        ) {
        let semaphore = DispatchSemaphore(value: 0)
        let controller = controllerMaker.shareController()
        var context = context
        
        shareWorker.add(link: context.link)
        shareWorker.upload(images: context.images, in: session)
        
        uiSyncQueue.async { [weak controller, shareWorker]  in
            controller?.share(
                context,
                onPost: { context in
                    controller?.enablePostButton(false)
                    
                    shareWorker.post(
                        context: context,
                        in: session,
                        onSuccess: {
                            controller?.close()
                            try onSuccess($0)
                        },
                        onError: {
                            controller?.enablePostButton(true)

                            if context.canShowError {
                                controller?.showError(
                                    title: NSLocalizedString("Error", bundle: Resources.bundle, comment: ""),
                                    message: NSLocalizedString("Something went wrong", bundle: Resources.bundle, comment: ""),
                                    buttontext: NSLocalizedString("Close", bundle: Resources.bundle, comment: "")
                                )
                            }
                            
                            onError($0)
                        }
                    )
                },
                onDismiss: {
                    shareWorker.clear(context: context)
                    semaphore.signal()
                }
            )
            
            semaphore.wait()
        }
    }
}
