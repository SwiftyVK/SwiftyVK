import CoreLocation

public enum UploadTarget {
    case user(id: String)
    case group(id: String)

    var decoded: (userId: String?, groupId: String?) {
        switch self {
        case .user(let id):
            return (userId: id, groupId: nil)
        case .group(let id):
            return (userId: nil, groupId: id)
        }
    }
}

extension VKAPI {
    //Metods to upload Mediafiles
    public struct Upload {
        ///Methods to upload photo
        public struct Photo {
            ///Upload photo to user album
            public static func toAlbum(
                _ media: [Media],
                to target: UploadTarget,
                albumId: String,
                caption: String? = nil,
                location: CLLocationCoordinate2D? = nil,
                config: Config = .default,
                uploadTimeout: TimeInterval = 30
                ) -> Method {
                
                return VKAPI.Photos.getUploadServer([
                    .albumId: albumId,
                    .userId: target.decoded.userId,
                    .groupId: target.decoded.groupId
                    ])
                    .chain {
                        let response = try JSON(data: $0)
                        
                        return Request(
                            type: .upload(
                                url: response.forcedString("upload_url"),
                                media: Array(media.prefix(5)),
                                partType: .indexedFile
                            ),
                            config: config.overriden(attemptTimeout: uploadTimeout)
                            )
                            .toMethod()
                    }
                    .chain {
                        let response = try JSON(data: $0)
                        
                        return VKAPI.Photos.save([
                            .albumId: albumId,
                            .userId: target.decoded.userId,
                            .groupId: target.decoded.groupId,
                            .server: response.forcedInt("server").toString(),
                            .photosList: response.forcedString("photos_list"),
                            .aid: response.forcedInt("aid").toString(),
                            .hash: response.forcedString("hash"),
                            .caption: caption,
                            .latitude: location?.latitude.toString(),
                            .longitude: location?.longitude.toString()
                            ])
                    }
            }

        ///Upload photo to message
//        public static func toMessage(
//            _ media: Media,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//
//            return VKAPI.Photos.getMessagesUploadServer(.empty)
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .photo
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Photos.saveMessagesPhoto([
//                        .photo: $0["photo"].string,
//                        .server: $0["server"].string,
//                        .hash: $0["hash"].string
//                        ])
//                        .request(with: config)
//            }
//        }

        ///Upload photo to market
//        public static func toMarket(
//            _ media: Media,
//            mainPhotoConfig: (cropX: String?, cropY: String?, cropW: String?)?,
//            groupId: String,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//
//            return VKAPI.Photos.getMarketUploadServer([.groupId: groupId])
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .file
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Photos.saveMarketPhoto([
//                        .groupId: groupId,
//                        .photo: $0["photo"].string,
//                        .server: $0["server"].string,
//                        .hash: $0["hash"].string,
//                        .cropData: $0["crop_data"].string,
//                        .cropHash: $0["crop_hash"].string,
//                        .mainPhoto: (mainPhotoConfig != nil ? "1" : "0"),
//                        .cropX: mainPhotoConfig?.cropX,
//                        .cropY: mainPhotoConfig?.cropY,
//                        .cropWidth: mainPhotoConfig?.cropW
//                        ])
//                        .request(with: config)
//            }
//        }

        ///Upload photo to market album
//        public static func toMarketAlbum(
//            _ media: Media,
//            groupId: String,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//
//            return VKAPI.Photos.getMarketAlbumUploadServer([.groupId: groupId])
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .file
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Photos.saveMarketAlbumPhoto([
//                        .groupId: groupId,
//                        .photo: $0["photo"].string,
//                        .server: $0["server"].string,
//                        .hash: $0["hash"].string
//                        ])
//                        .request(with: config)
//            }
//        }

        ///Upload photo to user or group wall
//        public static func toWall(
//            _ media: Media,
//            to target: UploadTarget,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//            return VKAPI.Photos.getWallUploadServer([
//                .userId: target.decoded.userId,
//                .groupId: target.decoded.groupId
//                ])
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .photo
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Photos.saveWallPhoto([
//                        .userId: target.decoded.userId,
//                        .groupId: target.decoded.groupId,
//                        .photo: $0["photo"].string,
//                        .server: $0["server"].string,
//                        .hash: $0["hash"].string
//                        ])
//                        .request(with: config)
//            }
        }

        ///Upload video from file or url
        public struct Video {
            //Upload local video file
//            public static func fromFile(
//                _ media: Media,
//                name: String? = nil,
//                description: String? = nil,
//                groupId: String? = nil,
//                albumId: String? = nil,
//                isPrivate: Bool = false,
//                isWallPost: Bool = false,
//                isRepeat: Bool = false,
//                isNoComments: Bool = false,
//                config: Config = .default,
//                uploadTimeout: TimeInterval = 30
//                ) -> Request {
//
//                return VKAPI.Video.save([
//                    .link: "",
//                    .name: name,
//                    .description: description,
//                    .groupId: groupId,
//                    .albumId: albumId,
//                    .isPrivate: isPrivate ? "1" : "0",
//                    .wallpost: isWallPost ? "1" : "0",
//                    .`repeat`: isRepeat ? "1" : "0"
//                    ])
//                    .request(with: config)
//                    .next {
//                        Request(
//                            of: .upload(
//                                url: $0["upload_url"].stringValue,
//                                media: [media],
//                                partType: .video
//                            ),
//                            config: config.overriden(attemptTimeout: uploadTimeout)
//                        )
//                }
//            }

            ///Upload local video from external resource
//            public static func fromUrl(
//                _ url: String? = nil,
//                name: String? = nil,
//                description: String? = nil,
//                groupId: String? = nil,
//                albumId: String? = nil,
//                isPrivate: Bool = false,
//                isWallPost: Bool = false,
//                isRepeat: Bool = false,
//                isNoComments: Bool = false,
//                config: Config = .default
//                ) -> Request {
//
//                return VKAPI.Video.save([
//                    .link: url,
//                    .name: name,
//                    .description: description,
//                    .groupId: groupId,
//                    .albumId: albumId,
//                    .isPrivate: isPrivate ? "1" : "0",
//                    .wallpost: isWallPost ? "1" : "0",
//                    .`repeat`: isRepeat ? "1" : "0"
//                    ])
//                    .request(with: config)
//            }
//        }

        ///Upload audio
//        public static func audio(
//            _ media: Media,
//            artist: String? = nil,
//            title: String? = nil,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//            return VKAPI.Audio.getUploadServer(.empty)
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .file
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Audio.save([
//                        .audio: $0["audio"].stringValue,
//                        .server: $0["server"].stringValue,
//                        .hash: $0["hash"].stringValue,
//                        .artist: artist,
//                        .title: title
//                        ])
//                        .request(with: config)
//            }
//        }

        ///Upload document
//        public static func document(
//            _ media: Media,
//            groupId: String? = nil,
//            title: String? = nil,
//            tags: String? = nil,
//            config: Config = .default,
//            uploadTimeout: TimeInterval = 30
//            ) -> Request {
//
//            return VKAPI.Docs.getUploadServer([.groupId: groupId])
//                .request(with: config)
//                .next {
//                    Request(
//                        of: .upload(
//                            url: $0["upload_url"].stringValue,
//                            media: [media],
//                            partType: .file
//                        ),
//                        config: config.overriden(attemptTimeout: uploadTimeout)
//                    )
//                }
//                .next {
//                    VKAPI.Docs.save([
//                        .file: $0["file"].string,
//                        .title: title,
//                        .tags: tags
//                        ])
//                        .request(with: config)
//
//            }
        }
    }
}
