import CoreLocation



extension _VKAPI {
  //Metods to upload mediafiles
  public struct Upload {
    ///Methods to upload photo
    public struct Photo {
      ///Upload photo to user album
      public static func toAlbum(
        _ media: [Media],
        albumId : String,
        groupId : String = "",
        caption: String = "",
        location: CLLocationCoordinate2D? = nil) -> Request {
        
        var _media = [Media]()
        for element in media[0..<min(media.count, 5)] {
          _media.append(element)
        }
        
        let req1 = VK.API.Photos.getUploadServer([VK.Arg.albumId : albumId, VK.Arg.groupId : groupId])
        let req2 = Request(url: "", media: _media)
        let req3 = VK.API.Photos.save()
        
        VK.Log.put(req1, "Prepare upload photo to album: \(albumId)")
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.asynchronous = req1.asynchronous
          req2.progressBlock = req1.progressBlock
          req2.errorBlock = req1.errorBlock
          req2.successBlock = {(response2: JSON) in
            req3.addParameters([
              VK.Arg.albumId : albumId,
              VK.Arg.groupId : groupId,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.photosList : response2["photos_list"].stringValue,
              VK.Arg.aid : response2["aid"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue,
              VK.Arg.caption : caption
              ])
            if let lat = location?.latitude, let lon = location?.longitude {
              req3.addParameters([
                VK.Arg.latitude : String(lat),
                VK.Arg.longitude : String(lon)
                ])
            }
            req3.asynchronous = req1.asynchronous
            req3.errorBlock = req1.errorBlock
            VK.Log.put(req1, "Save with request \(req3.id)")
            req3.send()
          }
          VK.Log.put(req1, "Upload with request \(req2.id)")
          req2.send()
        }
        req1.progressBlock = VK.defaults.progressBlock
        req1.swappedRequest = req3
        return req1
      }
      
      
      
      ///Upload photo to message
      public static func toMessage(_ media: Media) -> Request {
        
        let req1 = VK.API.Photos.getMessagesUploadServer()
        let req2 = Request(url: "", media: [media])
        let req3 = VK.API.Photos.saveMessagesPhoto()
        
        VK.Log.put(req1, "Prepare upload photo to message")
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.asynchronous = req1.asynchronous
          req2.progressBlock = req1.progressBlock
          req2.successBlock = {(response2: JSON) in
            req3.addParameters([
              VK.Arg.photo : response2["photo"].stringValue,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue
              ]
            )
            req3.asynchronous = req1.asynchronous
            req3.errorBlock = req1.errorBlock
            VK.Log.put(req1, "Save with request \(req3.id)")
            req3.send()
          }
          VK.Log.put(req1, "Upload with request \(req2.id)")
          req2.send()
        }
        req1.progressBlock = VK.defaults.progressBlock
        req1.swappedRequest = req3
        return req1
      }
      
      
      
      ///Upload photo to market
      public static func toMarket(
        _ media: Media,
        groupId: String,
        mainPhoto: Bool = false,
        cropX: String = "",
        cropY: String = "",
        cropW: String = "200"
        ) -> Request {
        
        let req1 = VK.API.Photos.getMarketUploadServer([VK.Arg.groupId: groupId])
        if mainPhoto {
          req1.addParameters([
            VK.Arg.mainPhoto: "1",
            VK.Arg.cropX: cropX,
            VK.Arg.cropY: cropY,
            VK.Arg.cropWidth: cropW
            ])
        }
        let req2 = Request(url: "", media: [media])
        let req3 = VK.API.Photos.saveMarketPhoto()
        
        VK.Log.put(req1, "Prepare upload photo to market")
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.asynchronous = req1.asynchronous
          req2.progressBlock = req1.progressBlock
          req2.successBlock = {(response2: JSON) in
            req3.addParameters([
              VK.Arg.groupId: groupId,
              VK.Arg.photo : response2["photo"].stringValue,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue,
              VK.Arg.cropData: response2["crop_data"].stringValue,
              VK.Arg.cropHash: response2["crop_hash"].stringValue
              ]
            )
            req3.asynchronous = req1.asynchronous
            req3.errorBlock = req1.errorBlock
            VK.Log.put(req1, "Save with request \(req3.id)")
            req3.send()
          }
          VK.Log.put(req1, "Upload with request \(req2.id)")
          req2.send()
        }
        req1.progressBlock = VK.defaults.progressBlock
        req1.swappedRequest = req3
        return req1
      }
      
      
      
      ///Upload photo to market album
      public static func toMarketAlbum(_ media: Media, groupId: String) -> Request {
        let req1 = VK.API.Photos.getMarketAlbumUploadServer([VK.Arg.groupId: groupId,])
        let req2 = Request(url: "", media: [media])
        let req3 = VK.API.Photos.saveMarketAlbumPhoto()
        
        VK.Log.put(req1, "Prepare upload photo to market album")
        req1.successBlock = {(response1: JSON) in
          printSync(response1)
          req2.customURL = response1["upload_url"].stringValue
          req2.asynchronous = req1.asynchronous
          req2.progressBlock = req1.progressBlock
          req2.successBlock = {(response2: JSON) in
            printSync(response2)
            req3.addParameters([
              VK.Arg.groupId: groupId,
              VK.Arg.photo : response2["photo"].stringValue,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue,
              ]
            )
            req3.asynchronous = req1.asynchronous
            req3.errorBlock = req1.errorBlock
            VK.Log.put(req1, "Save with request \(req3.id)")
            req3.send()
          }
          VK.Log.put(req1, "Upload with request \(req2.id)")
          req2.send()
        }
        req1.progressBlock = VK.defaults.progressBlock
        req1.swappedRequest = req3
        return req1
      }
      
      
      
      ///Upload photo to user or group wall
      public struct toWall {
        ///Upload photo to user wall
        public static func toUser(_ media: Media, userId : String) -> Request {
          return pToWall(media, userId: userId)
        }
        
        
        
        ///Upload photo to group wall
        public static func toGroup(_ media: Media, groupId : String) -> Request {
          return pToWall(media, groupId: groupId)
        }
        
        
        
        ///Upload photo to user or group wall
        private static func pToWall(_ media: Media, userId : String = "", groupId : String = "") -> Request {
          
          let req1 = VK.API.Photos.getWallUploadServer([VK.Arg.groupId : groupId])
          let req2 = Request(url: "", media: [media])
          let req3 = VK.API.Photos.saveWallPhoto()
          
          VK.Log.put(req1, "Prepare upload photo to wall")
          req1.successBlock = {response1 in
            req2.customURL = response1["upload_url"].stringValue
            req2.asynchronous = req1.asynchronous
            req2.progressBlock = req1.progressBlock
            req2.errorBlock = req1.errorBlock
            req2.successBlock = {response2 in
              req3.addParameters([
                VK.Arg.userId : userId,
                VK.Arg.groupId : groupId,
                VK.Arg.photo : response2["photo"].stringValue,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue,
                ]
              )
              req3.asynchronous = req1.asynchronous
              req3.errorBlock = req1.errorBlock
              VK.Log.put(req1, "Save with request \(req3.id)")
              req3.send()
            }
            VK.Log.put(req1, "Upload with request \(req2.id)")
            req2.send()
          }
          req1.progressBlock = VK.defaults.progressBlock
          req1.swappedRequest = req3
          return req1
        }
      }
    }
    
    
    
    ///Upload video from file or url
    public struct Video {
      ///Upload local video file
      public static func fromFile(
        _ media: Media,
        name: String = "No name",
        description : String = "",
        groupId : String = "",
        albumId : String = "",
        isPrivate : Bool = false,
        isWallPost : Bool = false,
        isRepeat : Bool = false,
        isNoComments : Bool = false
        ) -> Request {
        
        let req1 = VK.API.Video.save()
        let req2 = Request(url: "", media: [media])
        req1.addParameters([
          VK.Arg.link : "",
          VK.Arg.name : name,
          VK.Arg.description : description,
          VK.Arg.groupId : groupId,
          VK.Arg.albumId : albumId,
          VK.Arg.isPrivate : isPrivate ? "1" : "0",
          VK.Arg.wallpost : isWallPost ? "1" : "0",
          VK.Arg.`repeat` : isRepeat ? "1" : "0"
          ]
        )
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.asynchronous = req1.asynchronous
          req2.progressBlock = req1.progressBlock
          req2.errorBlock = req1.errorBlock
          req2.send()
        }
        req1.progressBlock = VK.defaults.progressBlock
        req1.swappedRequest = req2
        return req1
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
        ) -> Request {

        return VK.API.Video.save([
          VK.Arg.link : url,
          VK.Arg.name : name,
          VK.Arg.description : description,
          VK.Arg.groupId : groupId,
          VK.Arg.albumId : albumId,
          VK.Arg.isPrivate : isPrivate ? "1" : "0",
          VK.Arg.wallpost : isWallPost ? "1" : "0",
          VK.Arg.`repeat` : isRepeat ? "1" : "0"
          ]
        )
      }
    }
    
    
    
    ///Upload audio
    public static func audio(_ media: Media, artist : String = "", title: String = "") -> Request {
      let req1 = VK.API.Audio.getUploadServer()
      let req2 = Request(url: "", media: [media])
      let req3 = VK.API.Audio.save()
      
      VK.Log.put(req1, "Prepare upload audio")
      req1.successBlock = {(response1: JSON) in
        req2.customURL = response1["upload_url"].stringValue
        req2.asynchronous = req1.asynchronous
        req2.progressBlock = req1.progressBlock
        req2.errorBlock = req1.errorBlock
        req2.successBlock = {(response2: JSON) in
          req3.addParameters([
            VK.Arg.audio : response2["audio"].stringValue,
            VK.Arg.server : response2["server"].stringValue,
            VK.Arg.hash : response2["hash"].stringValue,
            VK.Arg.artist : artist,
            VK.Arg.title : title,
            ]
          )
          req3.asynchronous = req1.asynchronous
          req3.errorBlock = req1.errorBlock
          VK.Log.put(req1, "Save with request \(req3.id)")
          req3.send()
        }
        VK.Log.put(req1, "Upload with request \(req2.id)")
        req2.send()
      }
      req1.progressBlock = VK.defaults.progressBlock
      req1.swappedRequest = req3
      return req1
    }
    
    
    
    ///Upload document
    public static func document(
      _ media: Media,
      groupId : String = "",
      title : String = "",
      tags : String = "") -> Request {
      let req1 = VK.API.Docs.getUploadServer([VK.Arg.groupId : groupId])
      let req2 = Request(url: "", media: [media])
      let req3 = VK.API.Docs.save()
      
      VK.Log.put(req1, "Prepare upload document")
      req1.successBlock = {(response1: JSON) in
        req2.customURL = response1["upload_url"].stringValue
        req2.asynchronous = req1.asynchronous
        req2.progressBlock = req1.progressBlock
        req2.errorBlock = req1.errorBlock
        req2.successBlock = {(response2: JSON) in
          req3.addParameters([
            VK.Arg.file : (response2["file"].stringValue),
            VK.Arg.title : title,
            VK.Arg.tags : tags,
            ]
          )
          req3.asynchronous = req1.asynchronous
          req3.errorBlock = req1.errorBlock
          VK.Log.put(req1, "Save with request \(req3.id)")
          req3.send()
        }
        VK.Log.put(req1, "Upload with request \(req2.id)")
        req2.send()
      }
      req1.progressBlock = VK.defaults.progressBlock
      req1.swappedRequest = req3
      return req1
    }
  }
}
