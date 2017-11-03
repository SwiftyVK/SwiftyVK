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
        var posted = false
        var context = context
        
        uiSyncQueue.async { [weak controller, shareWorker]  in
            controller?.showPlaceholder(true)
            
            shareWorker.getUserInfo(
                in: session,
                onSuccess: {
                    controller?.showPlaceholder(false)
                    shareWorker.add(link: context.link)
                    shareWorker.upload(images: context.images, in: session)
                    
                    context.preferences.append(ShareContextPreference(key: "friendsOnly", name: "friendsOnly", active: false))
                    
                    if $0.facebook {
                        context.preferences.append(ShareContextPreference(key: "facebook", name: "facebook", active: $0.facebook))
                    }
                    
                    if $0.twitter {
                        context.preferences.append(ShareContextPreference(key: "twitter", name: "twitter", active: $0.twitter))
                    }
                    
                    if $0.livejournal {
                        context.preferences.append(ShareContextPreference(key: "livejournal", name: "livejournal", active: $0.livejournal))
                    }
                    
                    controller?.share(
                        context,
                        onPost: { context in
                            controller?.enablePostButton(false)
                            
                            shareWorker.post(
                                context: context,
                                in: session,
                                onSuccess: {
                                    posted = true
                                    controller?.close()
                                    try onSuccess($0)
                                },
                                onError: {
                                    posted = true
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
                            if !posted {
                                onError(.sharingWasDismissed)
                            }
                            
                            shareWorker.clear(context: context)
                            semaphore.signal()
                        }
                    )
                },
                onError: {
                    onError($0)
                    semaphore.signal()
                }
            )
            
            semaphore.wait()
        }
    }
    
    deinit {
        print("DEINIT", type(of: self))
    }
}
