protocol ShareWorker {
    func add(link: ShareLink?)
    func upload(images: [ShareImage], in session: Session)
    func getUserInfo(in session: Session) throws -> ShareContextPreferencesSet
    func post(context: ShareContext, in session: Session) throws -> Data
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
    
    func getUserInfo(in session: Session) throws -> ShareContextPreferencesSet {
        let data = try VK.API.Users.get([Parameter.fields: "exports"]).await()
        let json = try JSON(data: data)
        
        return ShareContextPreferencesSet(
            twitter: json.forcedBool("0, exports, twitter"),
            facebook: json.forcedBool("0, exports, facebook"),
            livejournal: json.forcedBool("0, exports, livejournal")
        )
    }
    
    func upload(images: [ShareImage], in session: Session)  {
        images.forEach { _ in group.enter() }
        
        for image in images {
            image.state = .uploading
            
            tasks += VK.API.Upload.Photo.toWall(.image(data: image.data, type: image.type), to: .user(id: ""))
                .onSuccess { [weak self] data in
                    image.state = try self?.parseImage(from: data) ?? .failed
                }
                .onError { [weak self]  _ in
                    defer { self?.group.leave() }
                    image.state = .failed
                }
                .send(in: session)
        }
    }
    
    func post(context: ShareContext, in session: Session) throws -> Data {
        group.wait()
        
        let friendsOnly = context.preferences
            .first { $0.key == "friendsOnly" }?.active ?? false
        
        let services = context.preferences
            .filter { $0.key != "friendsOnly" && $0.active == true }
            .map { $0.key }
        
        return try VK.API.Wall.post([
            .message: context.message ?? context.link?.title,
            .friendsOnly : String(friendsOnly),
            .services: services.joined(separator: ","),
            .attachments: attachements.joined(separator: ",")
            ])
            .await(in: session)
    }
    
    func clear(context: ShareContext) {
        tasks.forEach { $0.cancel() }
        
        context.images
            .filter { $0.state == .uploading }
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
