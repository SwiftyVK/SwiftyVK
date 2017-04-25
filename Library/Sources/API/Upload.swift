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

extension VK.Api {
    //Metods to upload Mediafiles
    public struct Upload {
        ///Methods to upload photo
        public struct Photo {
            ///Upload photo to user album
            public static func toAlbum(
                _ media: [Media],
                target: UploadTarget,
                albumId: String,
                caption: String = "",
                location: CLLocationCoordinate2D? = nil,
                config: Config = .default,
                uploadTimeout: TimeInterval = 30
                ) -> Request {
                
                return VK.Api.Photos.getUploadServer([
                    .albumId: albumId,
                    .userId: target.decoded.userId,
                    .groupId: target.decoded.groupId
                    ])
                    .request(with: config)
                    .next {
                        Request(
                            of: .upload(
                                url: $0["upload_url"].stringValue,
                                media: Array(media.prefix(5)
                                )
                            ),
                            config: config.mutatedWith(timeout: uploadTimeout)
                        )
                    }
                    .next {
                        VK.Api.Photos.save([
                            .albumId: albumId,
                            .userId: target.decoded.userId,
                            .groupId: target.decoded.groupId,
                            .server: $0["server"].stringValue,
                            .photosList: $0["photos_list"].stringValue,
                            .aid: $0["aid"].stringValue,
                            .hash: $0["hash"].stringValue,
                            .caption: caption,
                            .latitude: location?.latitude.toString(),
                            .longitude: location?.longitude.toString()
                            ]).request()
                }
            }
        }

//            ///Upload photo to message
//            public static func toMessage(_ media: Media) -> RequestConfig {
//                var getServerReq = Api.Photos.getMessagesUploadServer()
//
//                getServerReq.next {response -> RequestConfig in
//                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                    uploadReq.next {response -> RequestConfig in
//                        return Api.Photos.saveMessagesPhoto([
//                            .photo: response["photo"].stringValue,
//                            .server: response["server"].stringValue,
//                            .hash: response["hash"].stringValue
//                            ])
//                    }
//                    return uploadReq
//                }
//                return getServerReq
//            }
//
//            ///Upload photo to market
//            public static func toMarket(
//                _ media: Media,
//                groupId: String,
//                mainPhoto: Bool = false,
//                cropX: String = "",
//                cropY: String = "",
//                cropW: String = ""
//                ) -> RequestConfig {
//
//                var getServerReq = Api.Photos.getMarketUploadServer([.groupId: groupId])
//                if mainPhoto {
//                    getServerReq.add(parameters: [
//                        .mainPhoto: "1",
//                        .cropX: cropX,
//                        .cropY: cropY,
//                        .cropWidth: cropW
//                        ])
//                }
//
//                getServerReq.next {response -> RequestConfig in
//                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                    uploadReq.next {response -> RequestConfig in
//                        return Api.Photos.saveMarketPhoto([
//                            .groupId: groupId,
//                            .photo: response["photo"].stringValue,
//                            .server: response["server"].stringValue,
//                            .hash: response["hash"].stringValue,
//                            .cropData: response["crop_data"].stringValue,
//                            .cropHash: response["crop_hash"].stringValue
//                            ])
//                    }
//
//                    return uploadReq
//                }
//                return getServerReq
//            }
//
//            ///Upload photo to market album
//            public static func toMarketAlbum(_ media: Media, groupId: String) -> RequestConfig {
//                var getServerReq = Api.Photos.getMarketAlbumUploadServer([.groupId: groupId])
//
//                getServerReq.next {response -> RequestConfig in
//                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                    uploadReq.next {response -> RequestConfig in
//                        return Api.Photos.saveMarketAlbumPhoto([
//                            .groupId: groupId,
//                            .photo: response["photo"].stringValue,
//                            .server: response["server"].stringValue,
//                            .hash: response["hash"].stringValue
//                            ])
//                    }
//                    return uploadReq
//                }
//                return getServerReq
//            }
//
//            // swiftlint:disable type_name
//            ///Upload photo to user or group wall
//            public struct toWall {
//                // swiftlint:enable type_name
//                ///Upload photo to user wall
//                public static func toUser(_ media: Media, userId: String) -> RequestConfig {
//                    return pToWall(media, userId: userId)
//                }
//
//                ///Upload photo to group wall
//                public static func toGroup(_ media: Media, groupId: String) -> RequestConfig {
//                    return pToWall(media, groupId: groupId)
//                }
//
//                ///Upload photo to user or group wall
//                private static func pToWall(_ media: Media, userId: String = "", groupId: String = "") -> RequestConfig {
//                    var getServerReq = Api.Photos.getWallUploadServer([.groupId: groupId])
//
//                    getServerReq.next {response -> RequestConfig in
//                        var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                        uploadReq.next {response -> RequestConfig in
//                            return Api.Photos.saveWallPhoto([
//                                .userId: userId,
//                                .groupId: groupId,
//                                .photo: response["photo"].stringValue,
//                                .server: response["server"].stringValue,
//                                .hash: response["hash"].stringValue
//                                ])
//                        }
//                        return uploadReq
//                    }
//
//                    return getServerReq
//                }
//            }
//        }
//
//        ///Upload video from file or url
//        public struct Video {
//            ///Upload local video file
//            public static func fromFile(
//                _ media: Media,
//                name: String = "No name",
//                description: String = "",
//                groupId: String = "",
//                albumId: String = "",
//                isPrivate: Bool = false,
//                isWallPost: Bool = false,
//                isRepeat: Bool = false,
//                isNoComments: Bool = false
//                ) -> RequestConfig {
//
//                var saveReq = Api.Video.save([
//                    .link: "",
//                    .name: name,
//                    .description: description,
//                    .groupId: groupId,
//                    .albumId: albumId,
//                    .isPrivate: isPrivate ? "1" : "0",
//                    .wallpost: isWallPost ? "1" : "0",
//                    .`repeat`: isRepeat ? "1" : "0"
//                    ])
//
//                saveReq.next {response -> RequestConfig in
//                    return RequestConfig(url: response["upload_url"].stringValue, media: [media])
//                }
//                return saveReq
//            }
//
//            ///Upload local video from external resource
//            public static func fromUrl(
//                _ url: String,
//                name: String = "No name",
//                description: String = "",
//                groupId: String = "",
//                albumId: String = "",
//                isPrivate: Bool = false,
//                isWallPost: Bool = false,
//                isRepeat: Bool = false,
//                isNoComments: Bool = false
//                ) -> RequestConfig {
//
//                return Api.Video.save([
//                    .link: url,
//                    .name: name,
//                    .description: description,
//                    .groupId: groupId,
//                    .albumId: albumId,
//                    .isPrivate: isPrivate ? "1" : "0",
//                    .wallpost: isWallPost ? "1" : "0",
//                    .`repeat`: isRepeat ? "1" : "0"
//                    ]
//                )
//            }
//        }
//
//        ///Upload audio
//        public static func audio(_ media: Media, artist: String = "", title: String = "") -> RequestConfig {
//            var getServierReq = Api.Audio.getUploadServer()
//
//            getServierReq.next {response -> RequestConfig in
//                var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                uploadReq.next {response -> RequestConfig in
//                    return Api.Audio.save([
//                        .audio: response["audio"].stringValue,
//                        .server: response["server"].stringValue,
//                        .hash: response["hash"].stringValue,
//                        .artist: artist,
//                        .title: title
//                        ])
//                }
//                return uploadReq
//            }
//            return getServierReq
//        }
//
//        ///Upload document
//        public static func document(
//            _ media: Media,
//            groupId: String = "",
//            title: String = "",
//            tags: String = "") -> RequestConfig {
//            var getServierReq = Api.Docs.getUploadServer([.groupId: groupId])
//
//            getServierReq.next {response -> RequestConfig in
//                var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [media])
//
//                uploadReq.next {response -> RequestConfig in
//                    return Api.Docs.save([
//                        .file: (response["file"].stringValue),
//                        .title: title,
//                        .tags: tags
//                        ])
//                }
//                return uploadReq
//            }
//            return getServierReq
//        }
    }
}
