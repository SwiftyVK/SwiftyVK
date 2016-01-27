import XCTest
@testable import SwiftyVK


class Upload_Tests: VKTestCase {
  
  
  
  func test_upload_photo_to_message() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) else {
      XCTFail("Image path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.Photo.toMessage(media: Media(imageData: data, type: .JPG))
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_upload_photo_to_wall() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) else {
      XCTFail("Image path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.Photo.toWall(
      media: Media(imageData: data, type: .JPG),
      userId: nil,
      groupId: "60479154")
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_upload_photo_to_album() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) else {
      XCTFail("Image path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.Photo.toAlbum(
      media: [Media(imageData: data, type: .JPG)],
      albumId: "181808365",
      groupId: "60479154",
      caption: "test",
      location: nil)
    req.successBlock = {response in
      print(req)
      let deleteReq = VK.API.Photos.delete([VK.Arg.photoId : response[0]["id"].stringValue])
      deleteReq.isAsynchronous = true
      deleteReq.send()
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  func test_upload_audio() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testAudio", ofType: "mp3")!) else {
      XCTFail("Audio path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.audio(
      media: Media(audioData: data),
      artist: nil,
      title: nil)
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      let deleteReq = VK.API.Audio.delete([
        VK.Arg.audioId : response["id"].stringValue,
        VK.Arg.ownerId : response["owner_id"].stringValue
        ])
      deleteReq.isAsynchronous = false
      deleteReq.send()
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  func test_upload_video_from_file() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testVideo", ofType: "mp4")!) else {
      XCTFail("Video path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.video(
      media: Media(videoData: data),
      link: nil,
      name: "test video",
      description: "test",
      groupId: nil,
      albumId: nil,
      isPrivate: true,
      isWallPost: false,
      isRepeat: false)!
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      let deleteReq = VK.API.Audio.delete([
        VK.Arg.audioId : response["id"].stringValue,
        VK.Arg.ownerId : response["owner_id"].stringValue
        ])
      deleteReq.isAsynchronous = false
      deleteReq.send()
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  
  func test_upload_video_from_link() {
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.video(
      media: nil,
      link: "http://www.youtube.com/watch?v=w7VD1681jV8",
      name: "test video",
      description: "test",
      groupId: nil,
      albumId: nil,
      isPrivate: true,
      isWallPost: false,
      isRepeat: false)!
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      let deleteReq = VK.API.Audio.delete([
        VK.Arg.audioId : response["id"].stringValue,
        VK.Arg.ownerId : response["owner_id"].stringValue
        ])
      deleteReq.isAsynchronous = false
      deleteReq.send()
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  
  func test_upload_document() {
    guard let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testDoc", ofType: "rtf")!) else {
      XCTFail("Document path is empty")
      return
    }
    
    let readyExpectation = expectationWithDescription("ready")
    let req = VK.API.Upload.document(
      media: Media(documentData: data, type: "rtf"),
      groupId: nil,
      title: "test",
      tags: nil)
    req.isAsynchronous = true
    req.progressBlock = {done, total in}
    req.successBlock = {response in
      let deleteReq = VK.API.Audio.delete([
        VK.Arg.audioId : response["id"].stringValue,
        VK.Arg.ownerId : response["owner_id"].stringValue
        ])
      deleteReq.isAsynchronous = false
      deleteReq.send()
      printSync("success request \(response)")
      readyExpectation.fulfill()
    }
    req.errorBlock = {error in
      XCTFail("Error request \(error)")
      readyExpectation.fulfill()
    }
    req.progressBlock = {done, total in print ("upload \(done) in \(total)")}
    req.send()
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
}
