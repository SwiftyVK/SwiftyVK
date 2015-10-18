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
        location: CLLocationCoordinate2D?,
        isAsynchronous: Bool,
        progressBlock: (done: Int, total: Int) -> (),
        successBlock:(JSON) -> (),
        errorBlock:(VK.Error) -> ()) {
          Log([.upload], "Upload photo to album: \(albumId)")
          
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
          
          Log([.upload], "Get uploading server...")
          let req1 = VK.API.Photos.getUploadServer([VK.Arg.albumId : albumId, VK.Arg.groupId : localGroupId])
          req1.isAsynchronous = isAsynchronous
          req1.errorBlock = errorBlock
          req1.successBlock = {(response1: JSON) in
            Log([.upload], "Upload...")
            
            let req2 = Request(url: response1["upload_url"].stringValue, media: _media)
            req2.isAsynchronous = isAsynchronous
            req2.progressBlock = progressBlock
            req2.errorBlock = errorBlock
            req2.successBlock = {(response2: JSON) in
              Log([.upload], "Save...")
              let req3 = VK.API.Photos.save([
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
              req3.isAsynchronous = isAsynchronous
              req3.send(successBlock, errorBlock)
            }
            req2.send()
          }
          req1.send()
      }
      
      
      
      ///Upload photo to user or group wall
      public static func toWall(
        media media: Media,
        userId : String?,
        groupId : String?,
        isAsynchronous: Bool,
        progressBlock: (done: Int, total: Int) -> (),
        successBlock:(JSON) -> (),
        errorBlock:(VK.Error) -> ()) {
          var localUserId = String()
          var localGroupId = String()

          if userId != nil {
            localUserId = userId!
            Log([.upload], "Upload photo to user wall: \(userId!)")
          }
          else if groupId != nil {
            localGroupId = groupId!
            Log([.upload], "Upload photo to community wall: \(groupId!)")
          }
          Log([.upload], "Get upload server")
          let req1 = VK.API.Photos.getWallUploadServer([VK.Arg.groupId : localGroupId])
          req1.isAsynchronous = isAsynchronous
          req1.errorBlock = errorBlock
          req1.successBlock = {response1 in
            Log([.upload], "Upload...")
            let req2 = Request(url: response1["upload_url"].stringValue, media: [media])
            req2.isAsynchronous = isAsynchronous
            req2.progressBlock = progressBlock
            req2.errorBlock = errorBlock
            req2.successBlock = {response2 in
              Log([.upload], "Save...")
              let req3 = VK.API.Photos.saveWallPhoto([
                VK.Arg.userId : localUserId,
                VK.Arg.groupId : localGroupId,
                VK.Arg.photo : response2["photo"].stringValue,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue,
                ]
              )
              req3.isAsynchronous = isAsynchronous
              req3.send(successBlock, errorBlock)
            }
            req2.send()
          }
          req1.send()
      }
      
      
      
      ///Upload photo to message
      public static func toMessage(
        media media: Media,
        isAsynchronous: Bool,
        progressBlock: (done: Int, total: Int) -> (),
        successBlock:(JSON) -> (),
        errorBlock:(VK.Error) -> ()) {
          Log([.upload], "Get upload server...")
          let req1 = VK.API.Photos.getMessagesUploadServer(nil)
          req1.isAsynchronous = isAsynchronous
          req1.errorBlock = errorBlock
          req1.successBlock = {(response1: JSON) in
            Log([.upload], "Upload...")
            let req2 = Request(url: response1["upload_url"].stringValue, media: [media])
            req2.isAsynchronous = isAsynchronous
            req2.progressBlock = progressBlock
            req2.successBlock = {(response2: JSON) in
              Log([.upload], "Save...")
              let req3 = VK.API.Photos.saveMessagesPhoto([
                VK.Arg.photo : response2["photo"].stringValue,
                VK.Arg.server : response2["server"].stringValue,
                VK.Arg.hash : response2["hash"].stringValue
                ]
              )
              req3.isAsynchronous = isAsynchronous
              req3.send(successBlock, errorBlock)
            }
            req2.send()
          }
          req1.send()
      }
    }
    
    ///Upload audio
    public static func audio(
      media media: Media,
      artist : String?,
      title: String?,
      isAsynchronous: Bool,
      progressBlock: (done: Int, total: Int) -> (),
      successBlock:(JSON) -> (),
      errorBlock:(VK.Error) -> ()) {
        Log([.upload], "Get upload server...")
        let req1 = VK.API.Audio.getUploadServer(nil)
        req1.isAsynchronous = isAsynchronous
        req1.errorBlock = errorBlock
        req1.successBlock = {(response1: JSON) in
          Log([.upload], "Upload...")
          let req2 = Request(url: response1["upload_url"].stringValue, media: [media])
          req2.isAsynchronous = isAsynchronous
          req2.progressBlock = progressBlock
          req2.errorBlock = errorBlock
          req2.successBlock = {(response2: JSON) in
            Log([.upload], "Save...")
            let req3 = VK.API.Audio.save([
              VK.Arg.audio : response2["audio"].stringValue,
              VK.Arg.server : response2["server"].stringValue,
              VK.Arg.hash : response2["hash"].stringValue,
              VK.Arg.artist : artist != nil ? artist! : "",
              VK.Arg.title : title != nil ? title! : "",
              ]
            )
            req3.isAsynchronous = isAsynchronous
            req3.send(successBlock, errorBlock)
          }
          req2.send()
        }
        req1.send()
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
      isRepeat : Bool,
      isAsynchronous: Bool,
      progressBlock: (done: Int, total: Int) -> (),
      successBlock:(JSON) -> (),
      errorBlock:(VK.Error) -> ()) {
        if let media = media where link == nil {
          let req1 = VK.API.Video.save([
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
          req1.isAsynchronous = isAsynchronous
          req1.progressBlock = progressBlock
          req1.errorBlock = errorBlock
          req1.successBlock = {(response1: JSON) in
            let req2 = Request(url: response1["upload_url"].stringValue, media: [media])
            req2.isAsynchronous = isAsynchronous
            req2.send(successBlock, errorBlock)
          }
          req1.send()
        }
        else if let link = link where media == nil {
          let req1 = VK.API.Video.save([
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
          req1.isAsynchronous = isAsynchronous
          req1.progressBlock = progressBlock
          req1.send(successBlock, errorBlock)
        }
        else {
          errorBlock(VK.Error(domain: "VKSDKDomain", code: 2, desc: "Not file or link to upload file", userInfo: nil, req: nil))
        }
    }
    
    
    
    ///Upload document
    public static func document(
      media media: Media,
      groupId : String?,
      title : String?,
      tags : String?,
      isAsynchronous: Bool,
      progressBlock: (done: Int, total: Int) -> (),
      successBlock:(JSON) -> (),
      errorBlock:(VK.Error) -> ()) {
        Log([.upload], "Get upload server...")
        let req1 = VK.API.Docs.getUploadServer([VK.Arg.groupId : (groupId != nil) ? groupId! : ""])
        req1.isAsynchronous = isAsynchronous
        req1.errorBlock = errorBlock
        req1.successBlock = {(response1: JSON) in
          Log([.upload], "Upload...")
          let req2 = Request(url: response1["upload_url"].stringValue, media: [media])
          req2.isAsynchronous = isAsynchronous
          req2.errorBlock = errorBlock
          req2.successBlock = {(response2: JSON) in
            Log([.upload], "Save...")
            let req3 = VK.API.Docs.save([
              VK.Arg.file : (response2["file"].stringValue),
              VK.Arg.title : (title != nil) ? title! : "",
              VK.Arg.tags : (tags != nil) ? tags! : "",
              ]
            )
            req3.isAsynchronous = isAsynchronous
            req3.send(successBlock, errorBlock)
          }
          req2.send()
        }
        req1.send()
    }
  }
}
