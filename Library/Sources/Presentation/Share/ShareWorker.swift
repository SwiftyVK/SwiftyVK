protocol ShareWorker: class {
    func upload(images: [ShareImage], in session: Session)
    func getPrefrences(in session: Session) throws -> [ShareContextPreference]
    func post(context: ShareContext, in session: Session) throws -> Data?
    func clear(context: ShareContext)
}

final class ShareWorkerImpl: ShareWorker {
    private var group = DispatchGroup()
    private(set) var tasks = [Task]()
    
    func getPrefrences(in session: Session) throws -> [ShareContextPreference] {
        let data = try VK.API.Users.get([.fields: "exports"]).synchronously().send(in: session)
        let json = try JSON(data: data)
        var preferences = [ShareContextPreference]()
        
        preferences += ShareContextPreference(
            key: SettingKeys.friendsOnly.rawValue,
            name: Resources.localizedString(for: "FriendsOnly"),
            active: false
        )
        
        if let twitterExport = json.bool("0, exports, twitter") {
            preferences += ShareContextPreference(
                key: SettingKeys.twitter.rawValue,
                name: Resources.localizedString(for: "ExportTwitter"),
                active: twitterExport
            )
        }
        
        if let facebookExport = json.bool("0, exports, facebook") {
            preferences += ShareContextPreference(
                key: SettingKeys.facebook.rawValue,
                name: Resources.localizedString(for: "ExportFacebook"),
                active: facebookExport
            )
        }
        
        if let livejournalExport = json.bool("0, exports, livejournal") {
            preferences += ShareContextPreference(
                key: SettingKeys.livejournal.rawValue,
                name: Resources.localizedString(for: "ExportLivejournal"),
                active: livejournalExport
            )
        }
        
        return preferences
    }
    
    func upload(images: [ShareImage], in session: Session) {
        images.forEach { _ in group.enter() }
        
        for image in images {
            image.state = .uploading
            let media = Media.image(data: image.data, type: image.type)
            
            tasks += VK.API.Upload.Photo.toWall(media, to: .user(id: ""))
                .onSuccess { [weak self] data in
                    image.id = try self?.parseImage(from: data)
                    image.state = .uploaded
                    self?.group.leave()
                }
                .onError { [weak self] error in
                    print("image not uploaded with error: \(error)")
                    image.state = .failed
                    self?.group.leave()
                }
                .send(in: session)
        }
    }
    
    func post(context: ShareContext, in session: Session) throws -> Data? {
        group.wait()
        
        let friendsOnly = context.preferences
            .first { $0.key == SettingKeys.friendsOnly.rawValue }?.active ?? false
        
        let services = context.preferences
            .filter { $0.key != SettingKeys.friendsOnly.rawValue && $0.active == true }
            .map { $0.key }
        
        var attachements = context.images.flatMap { $0.id }
        
        if let link = context.link?.url.absoluteString {
            attachements.append(link)
        }
        
        let postTask = VK.API.Wall.post([
            .message: context.message ?? context.link?.title,
            .friendsOnly: friendsOnly ? "1" : "0",
            .services: services.joined(separator: ","),
            .attachments: attachements.joined(separator: ",")
            ])
            .synchronously()
        
        tasks += postTask
        return try postTask.send(in: session)
    }
    
    func clear(context: ShareContext) {
        tasks.forEach { $0.cancel() }
        
        context.images
            .filter { $0.state == .uploading }
            .forEach { _ in group.leave() }
    }
    
    private func parseImage(from data: Data) throws -> String {
        let json = try JSON(data: data)
        
        guard
            let photoId = json.int("0, id")?.toString(),
            let ownerId = json.int("0, owner_id")?.toString()
            else { throw VKError.unexpectedResponse }
        
        return String(format: "photo%@_%@", ownerId, photoId)
    }
}

private enum SettingKeys: String {
    case friendsOnly
    case facebook
    case twitter
    case livejournal
}
