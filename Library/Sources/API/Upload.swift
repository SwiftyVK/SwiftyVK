import CoreLocation



extension _VKAPI {
    //Metods to upload VKMediafiles
    public struct Upload {
        ///Methods to upload photo
        public struct Photo {
            ///Upload photo to user album
            public static func toAlbum(
                _ media: [VKMedia],
                albumId : String,
                groupId : String = "",
                caption: String = "",
                location: CLLocationCoordinate2D? = nil) -> RequestConfig {
                
                var getServerReq = VK.API.Photos.getUploadServer([.albumId : albumId, .groupId : groupId])
                
                getServerReq.next {response -> RequestConfig in
                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: Array(media.prefix(5)))
                    
                    uploadReq.next {response -> RequestConfig in
                        var saveReq = VK.API.Photos.save([
                            .albumId : albumId,
                            .groupId : groupId,
                            .server : response["server"].stringValue,
                            .photosList : response["photos_list"].stringValue,
                            .aid : response["aid"].stringValue,
                            .hash : response["hash"].stringValue,
                            .caption : caption
                            ])
                        
                        if let lat = location?.latitude, let lon = location?.longitude {
                            saveReq.parameters[.latitude] = String(lat)
                            saveReq.parameters[.longitude] = String(lon)
                        }
                        return saveReq
                    }
                    return uploadReq
                }
                return getServerReq
            }
            
            
            
            ///Upload photo to message
            public static func toMessage(_ VKMedia: VKMedia) -> RequestConfig {
                var getServerReq = VK.API.Photos.getMessagesUploadServer()
                
                getServerReq.next {response -> RequestConfig in
                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                    
                    uploadReq.next {response -> RequestConfig in
                        return VK.API.Photos.saveMessagesPhoto([
                            .photo : response["photo"].stringValue,
                            .server : response["server"].stringValue,
                            .hash : response["hash"].stringValue
                            ])
                    }
                    return uploadReq
                }
                return getServerReq
            }
            
            
            
            ///Upload photo to market
            public static func toMarket(
                _ VKMedia: VKMedia,
                groupId: String,
                mainPhoto: Bool = false,
                cropX: String = "",
                cropY: String = "",
                cropW: String = ""
                ) -> RequestConfig {
                
                var getServerReq = VK.API.Photos.getMarketUploadServer([.groupId: groupId])
                if mainPhoto {
                    getServerReq.add(parameters: [
                        .mainPhoto: "1",
                        .cropX: cropX,
                        .cropY: cropY,
                        .cropWidth: cropW
                        ])
                }
                
                getServerReq.next {response -> RequestConfig in
                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                    
                    uploadReq.next {response -> RequestConfig in
                        return VK.API.Photos.saveMarketPhoto([
                            .groupId: groupId,
                            .photo: response["photo"].stringValue,
                            .server: response["server"].stringValue,
                            .hash: response["hash"].stringValue,
                            .cropData: response["crop_data"].stringValue,
                            .cropHash: response["crop_hash"].stringValue
                            ])
                    }
                    
                    return uploadReq
                }
                return getServerReq
            }
            
            
            
            ///Upload photo to market album
            public static func toMarketAlbum(_ VKMedia: VKMedia, groupId: String) -> RequestConfig {
                var getServerReq = VK.API.Photos.getMarketAlbumUploadServer([.groupId: groupId,])
                
                getServerReq.next {response -> RequestConfig in
                    var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                    
                    uploadReq.next {response -> RequestConfig in
                        return VK.API.Photos.saveMarketAlbumPhoto([
                            .groupId: groupId,
                            .photo : response["photo"].stringValue,
                            .server : response["server"].stringValue,
                            .hash : response["hash"].stringValue,
                            ])
                    }
                    return uploadReq
                }
                return getServerReq
            }
            
            
            
            ///Upload photo to user or group wall
            public struct toWall {
                ///Upload photo to user wall
                public static func toUser(_ VKMedia: VKMedia, userId : String) -> RequestConfig {
                    return pToWall(VKMedia, userId: userId)
                }
                
                
                
                ///Upload photo to group wall
                public static func toGroup(_ VKMedia: VKMedia, groupId : String) -> RequestConfig {
                    return pToWall(VKMedia, groupId: groupId)
                }
                
                
                
                ///Upload photo to user or group wall
                private static func pToWall(_ VKMedia: VKMedia, userId : String = "", groupId : String = "") -> RequestConfig {
                    var getServerReq = VK.API.Photos.getWallUploadServer([.groupId : groupId])
                    
                    getServerReq.next {response -> RequestConfig in
                        var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                        
                        uploadReq.next {response -> RequestConfig in
                            return VK.API.Photos.saveWallPhoto([
                                .userId : userId,
                                .groupId : groupId,
                                .photo : response["photo"].stringValue,
                                .server : response["server"].stringValue,
                                .hash : response["hash"].stringValue,
                                ])
                        }
                        return uploadReq
                    }
                    
                    return getServerReq
                }
            }
        }
        
        
        
        ///Upload video from file or url
        public struct Video {
            ///Upload local video file
            public static func fromFile(
                _ VKMedia: VKMedia,
                name: String = "No name",
                description : String = "",
                groupId : String = "",
                albumId : String = "",
                isPrivate : Bool = false,
                isWallPost : Bool = false,
                isRepeat : Bool = false,
                isNoComments : Bool = false
                ) -> RequestConfig {
                
                var saveReq = VK.API.Video.save([
                    .link : "",
                    .name : name,
                    .description : description,
                    .groupId : groupId,
                    .albumId : albumId,
                    .isPrivate : isPrivate ? "1" : "0",
                    .wallpost : isWallPost ? "1" : "0",
                    .`repeat` : isRepeat ? "1" : "0"
                    ])
                
                saveReq.next {response -> RequestConfig in
                    return RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                }
                return saveReq
            }
            
            
            
            ///Upload local video from external resource
            public static func fromUrl(
                _ url : String,
                name: String = "No name",
                description : String = "",
                groupId : String = "",
                albumId : String = "",
                isPrivate : Bool = false,
                isWallPost : Bool = false,
                isRepeat : Bool = false,
                isNoComments : Bool = false
                ) -> RequestConfig {
                
                return VK.API.Video.save([
                    .link : url,
                    .name : name,
                    .description : description,
                    .groupId : groupId,
                    .albumId : albumId,
                    .isPrivate : isPrivate ? "1" : "0",
                    .wallpost : isWallPost ? "1" : "0",
                    .`repeat` : isRepeat ? "1" : "0"
                    ]
                )
            }
        }
        
        
        
        ///Upload audio
        public static func audio(_ VKMedia: VKMedia, artist : String = "", title: String = "") -> RequestConfig {
            var getServierReq = VK.API.Audio.getUploadServer()
            
            getServierReq.next {response -> RequestConfig in
                var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                
                uploadReq.next {response -> RequestConfig in
                    return VK.API.Audio.save([
                        .audio : response["audio"].stringValue,
                        .server : response["server"].stringValue,
                        .hash : response["hash"].stringValue,
                        .artist : artist,
                        .title : title,
                        ])
                }
                return uploadReq
            }
            return getServierReq
        }
        
        
        
        ///Upload document
        public static func document(
            _ VKMedia: VKMedia,
            groupId : String = "",
            title : String = "",
            tags : String = "") -> RequestConfig {
            var getServierReq = VK.API.Docs.getUploadServer([.groupId : groupId])
            
            getServierReq.next {response -> RequestConfig in
                var uploadReq = RequestConfig(url: response["upload_url"].stringValue, media: [VKMedia])
                
                uploadReq.next {response -> RequestConfig in
                    return VK.API.Docs.save([
                        .file : (response["file"].stringValue),
                        .title : title,
                        .tags : tags,
                        ])
                }
                return uploadReq
            }
            return getServierReq
        }
    }
}
