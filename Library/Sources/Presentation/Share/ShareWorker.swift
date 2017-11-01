protocol ShareWorker {
    func add(link: ShareLink?)
    func upload(images: [ShareImage], in session: Session)
    
    func post(
        context: ShareContext,
        in session: Session,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
    )
    
    func clear(context: ShareContext)
}

final class ShareWorkerImpl: ShareWorker {
    private var group = DispatchGroup()
    private var attachements = [String]()
    private var tasks = [Task]()
    
    func add(link: ShareLink?) {
        if let link = link?.url.absoluteString {
            attachements.append(link)
        }
    }
    
    func upload(images: [ShareImage], in session: Session)  {
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
    
    func post(
        context: ShareContext,
        in session: Session,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
        ) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.group.wait()
            
            self?.tasks += VK.API.Wall.post([
                .message: context.message ?? context.link?.title,
                .attachments: self?.attachements.joined(separator: ",")
                ])
                .onSuccess(onSuccess)
                .onError(onError)
                .send(in: session)
        }
    }
    
    func clear(context: ShareContext) {
        tasks.forEach { $0.cancel() }
        
        context.images
            .filter { $0.state == nil }
            .forEach { _ in group.leave() }
    }
    
    private func parseImage(from data: Data) throws -> ShareImageUploadState {
        defer { self.group.leave() }
        
        let json = try JSON(data: data)
        
        guard
            let photoId = json.int("0, id")?.toString(),
            let ownerId = json.int("0, owner_id")?.toString()
            else {
                return .failed
        }
        
        let imageId = String(format: "photo%@_%@", ownerId, photoId)
        attachements.append(imageId)
        
        return .uploaded
    }
}
