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
    private var group = DispatchGroup()
    private var attachements = [String]()
    private var tasks = [Task]()
    
    init(
        uiSyncQueue: DispatchQueue,
        controllerMaker: ShareControllerMaker
        ) {
        self.uiSyncQueue = uiSyncQueue
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
        
        if let link = context.link?.url.absoluteString {
            attachements.append(link)
        }
        
        upload(images: context.images, in: session)
        
        uiSyncQueue.async { [weak controller]  in
            controller?.share(
                context,
                onPost: { [weak self] context in
                    controller?.wait()
                    
                    self?.post(
                        in: session,
                        onSuccess: {
                            controller?.close()
                            try onSuccess($0)
                        },
                        onError: {
                            controller?.showError(
                                title: "@@@",
                                message: "!!!",
                                buttontext: "---"
                            )
                            onError($0)
                        }
                    )
                },
                onDismiss: { [weak self] in
                    self?.tasks.forEach { $0.cancel() }
                    
                    context.images
                        .filter { $0.state == nil }
                        .forEach { _ in self?.group.leave() }
                    
                    semaphore.signal()
                }
            )
            
            semaphore.wait()
        }
    }
    
    private func upload(images: [ShareImage], in session: Session)  {
        images.forEach { _ in group.enter() }
        
        for image in images {
            tasks += VK.API.Upload.Photo.toWall(.image(data: image.data, type: image.type), to: .user(id: ""))
                .onSuccess { [weak self] data in
                    image.state = try self?.parseImage(from: data)
                }
                .onError { [weak self]  _ in
                    defer { self?.group.leave() }
                    image.state = .failed
                }
                .send(in: session)
        }
    }
    
    func parseImage(from data: Data) throws -> ShareImageUploadState {
        defer { self.group.leave() }
        
        let json = try JSON(data: data)
        
        guard
            let photoId = json.int("0, id")?.toString(),
            let ownerId = json.int("0, owner_id")?.toString()
            else {
                return .failed
        }
        
        let imageId = String(format: "photo=%@_%@", ownerId, photoId)
        attachements.append(imageId)
        
        return .uploaded
    }
    
    private func post(
        in session: Session,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
        ) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.group.wait()
            
            self?.tasks += VK.API.Wall.post([
                .attachments: self?.attachements.joined(separator: ",")
                ])
                .onSuccess(onSuccess)
                .onError(onError)
                .send(in: session)
        }
    }
}
