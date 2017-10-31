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
        
        for image in context.images {
            VK.API.Upload.Photo.toWall(.image(data: image.data, type: image.type), to: .user(id: ""))
                .onSuccess { _ in
                    image.state = .uploaded
                }
                .onError { _ in
                    image.state = .failed
                }
                .send(in: session)
        }
    }
}
