import CoreLocation


extension _VKAPI {
  //Metods to upload mediafiles
  public struct Upload {
    ///Methods to upload photo
    public struct Photo {
      ///Upload photo to user album
      public static func toAlbum(
        media media: [Media],
        albumId : String,
        groupId : String?,
        caption: String,
        location: CLLocationCoordinate2D?) -> Request {
          
          var _media = [Media]()
          
          for (var i=0; i<media.count && i<5; i++) {
            _media.append(media[i])
          }
          
          var localGroupId = String()
          if groupId != nil {localGroupId = groupId!}
          var latitude = String()
          var longitude = String()
          
          if let lat = location?.latitude,  let lon = location?.longitude {
            latitude = String(lat)
            longitude = String(lon)
          }
          
          let req1 = VK.API.Photos.getUploadServer([VK.Arg.albumId : albumId, VK.Arg.groupId : localGroupId])
          let req2 = Request(url: "", media: _media)
          let req3 = VK.API.Photos.save(nil)
          
          VK.Log.put(req1, "Prepare upload photo to album: \(albumId)")
          req1.successBlock = {(response1: JSON) in
            req2.customURL = response1["upload_url"].stringValue
            req2.isAsynchronous = req1.isAsynchronous
            req2.progressBlock = req1.progressBlock
            req2.errorBlock = req1.errorBlock
            req2.successBlock = {(response2: JSON) in
              req3.addParameters([
                VK.Arg.albumId : albumId,
                VK.Arg.groupId : localGroupId,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.photosList : response2["photos_list"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue,
                VK.Arg.caption : caption,
                VK.Arg.latitude : latitude,
                VK.Arg.longitude : longitude
                ]
              )
              req3.isAsynchronous = req1.isAsynchronous
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
      public static func toWall(
        media media: Media,
        userId : String?,
        groupId : String?) -> Request {
          var localUserId = String()
          var localGroupId = String()
          
          if userId != nil {
            localUserId = userId!
          }
          else if groupId != nil {
            localGroupId = groupId!
          }
          let req1 = VK.API.Photos.getWallUploadServer([VK.Arg.groupId : localGroupId])
          let req2 = Request(url: "", media: [media])
          let req3 = VK.API.Photos.saveWallPhoto(nil)
          
          VK.Log.put(req1, "Prepare upload photo to wall")
          req1.successBlock = {response1 in
            req2.customURL = response1["upload_url"].stringValue
            req2.isAsynchronous = req1.isAsynchronous
            req2.progressBlock = req1.progressBlock
            req2.errorBlock = req1.errorBlock
            req2.successBlock = {response2 in
              req3.addParameters([
                VK.Arg.userId : localUserId,
                VK.Arg.groupId : localGroupId,
                VK.Arg.photo : response2["photo"].stringValue,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue,
                ]
              )
              req3.isAsynchronous = req1.isAsynchronous
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
      public static func toMessage(
        media media: Media) -> Request {
          let req1 = VK.API.Photos.getMessagesUploadServer(nil)
          let req2 = Request(url: "", media: [media])
          let req3 = VK.API.Photos.saveMessagesPhoto(nil)
          
          VK.Log.put(req1, "Prepare upload photo to message")
          req1.successBlock = {(response1: JSON) in
            req2.customURL = response1["upload_url"].stringValue
            req2.isAsynchronous = req1.isAsynchronous
            req2.progressBlock = req1.progressBlock
            req2.successBlock = {(response2: JSON) in
              req3.addParameters([
                VK.Arg.photo : response2["photo"].stringValue,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue
                ]
              )
              req3.isAsynchronous = req1.isAsynchronous
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
    
    
    
    ///Upload audio
    public static func audio(
      media media: Media,
      artist : String?,
      title: String?) -> Request {
        let req1 = VK.API.Audio.getUploadServer(nil)
        let req2 = Request(url: "", media: [media])
        let req3 = VK.API.Audio.save(nil)
        
        VK.Log.put(req1, "Prepare upload audio")
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.isAsynchronous = req1.isAsynchronous
          req2.progressBlock = req1.progressBlock
          req2.errorBlock = req1.errorBlock
          req2.successBlock = {(response2: JSON) in
            req3.addParameters([
              VK.Arg.audio : response2["audio"].stringValue,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue,
              VK.Arg.artist : artist != nil ? artist! : "",
              VK.Arg.title : title != nil ? title! : "",
              ]
            )
            req3.isAsynchronous = req1.isAsynchronous
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
    
    
    
    ///Upload video
    public static func video(
      media media: Media?,
      link : String?,
      name: String,
      description : String,
      groupId : String?,
      albumId : String?,
      isPrivate : Bool,
      isWallPost : Bool,
      isRepeat : Bool) -> Request? {
        if let media = media where link == nil {
          let req1 = VK.API.Video.save(nil)
          let req2 = Request(url: "", media: [media])
          req1.addParameters([
            VK.Arg.link : (link != nil) ? link! : "",
            VK.Arg.name : name,
            VK.Arg.description : description,
            VK.Arg.groupId : (groupId != nil) ? groupId! : "",
            VK.Arg.albumId : (albumId != nil) ? albumId! : "",
            VK.Arg.isPrivate : isPrivate ? "1" : "0",
            VK.Arg.wallpost : isWallPost ? "1" : "0",
            VK.Arg.`repeat` : isRepeat ? "1" : "0"
            ]
          )
          req1.successBlock = {(response1: JSON) in
            req2.customURL = response1["upload_url"].stringValue
            req2.isAsynchronous = req1.isAsynchronous
            req2.progressBlock = req1.progressBlock
            req2.errorBlock = req1.errorBlock
            req2.send()
          }
          req1.progressBlock = VK.defaults.progressBlock
          req1.swappedRequest = req2
          return req1
        }
        else if let link = link where media == nil {
          return VK.API.Video.save([
            VK.Arg.link : link,
            VK.Arg.name : name,
            VK.Arg.description : description,
            VK.Arg.groupId : (groupId != nil) ? groupId! : "",
            VK.Arg.albumId : (albumId != nil) ? albumId! : "",
            VK.Arg.isPrivate : isPrivate ? "1" : "0",
            VK.Arg.wallpost : isWallPost ? "1" : "0",
            VK.Arg.`repeat` : isRepeat ? "1" : "0"
            ]
          )
        }
        return nil
    }
    
    
    
    ///Upload document
    public static func document(
      media media: Media,
      groupId : String?,
      title : String?,
      tags : String?) -> Request {
        let req1 = VK.API.Docs.getUploadServer([VK.Arg.groupId : (groupId != nil) ? groupId! : ""])
        let req2 = Request(url: "", media: [media])
        let req3 = VK.API.Docs.save(nil)
        
        VK.Log.put(req1, "Prepare upload document")
        req1.successBlock = {(response1: JSON) in
          req2.customURL = response1["upload_url"].stringValue
          req2.isAsynchronous = req1.isAsynchronous
          req2.progressBlock = req1.progressBlock
          req2.errorBlock = req1.errorBlock
          req2.successBlock = {(response2: JSON) in
             req3.addParameters([
              VK.Arg.file : (response2["file"].stringValue),
              VK.Arg.title : (title != nil) ? title! : "",
              VK.Arg.tags : (tags != nil) ? tags! : "",
              ]
            )
            req3.isAsynchronous = req1.isAsynchronous
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
