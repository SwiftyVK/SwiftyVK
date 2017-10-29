protocol SharePresenter {
    func share(
        _ context: ShareContext,
        in session: Session,
        onSuccess: @escaping () -> (),
        onError: @escaping RequestCallbacks.Error
    )
}

final class SharePresenterImpl: SharePresenter {
    let controllerMaker: ShareControllerMaker
    
    init(controllerMaker: ShareControllerMaker) {
        self.controllerMaker = controllerMaker
    }
    
    
    func share(
        _ context: ShareContext,
        in session: Session,
        onSuccess: @escaping () -> (),
        onError: @escaping RequestCallbacks.Error
        ) {
        let controller = controllerMaker.shareController()
        
        controller?.share(context) { [weak controller] context in
            controller?.close()
        }
    }
}
