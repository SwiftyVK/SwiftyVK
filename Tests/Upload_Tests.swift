//
//  SwiftyVK_Upload_Tests.swift
//  SwiftyVKTestApp
//
//  Created by Алексей Кудрявцев on 16.07.15.
//  Copyright © 2015 Алексей Кудрявцев. All rights reserved.
//

import XCTest
@testable import SwiftyVK


class Upload_Tests: XCTestCase {
  
  
  
  func test_upload_photo_to_message() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) {
      let media = Media(imageData: data, type: .JPG)
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.Photo.toMessage(
        media: media,
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Image path is empty")
    }
  }
  
  
  
  func test_upload_photo_to_wall() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) {
      let media = Media(imageData: data, type: .JPG)
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.Photo.toWall(
        media: media,
        userId: nil,
        groupId: "60479154",
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Image path is empty")
    }
  }
  
  
  
  func test_upload_photo_to_album() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testImage", ofType: "jpg")!) {
      let media = Media(imageData: data, type: .JPG)
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.Photo.toAlbum(
        media: [media],
        albumId: "181808365",
        groupId: "60479154",
        caption: "test",
        location: nil,
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          let deleteReq = VK.API.Photos.delete([VK.Arg.photoId : response[0]["id"].stringValue])
          deleteReq.isAsynchronous = false
          deleteReq.send()
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
          readyExpectation.fulfill()
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Image path is empty")
    }
  }
  
  
  
  func test_upload_audio() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testAudio", ofType: "mp3")!) {
      let media = Media(audioData: data)
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.audio(
        media: media,
        artist: nil,
        title: nil,
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          let deleteReq = VK.API.Audio.delete([
            VK.Arg.audioId : response["id"].stringValue,
            VK.Arg.ownerId : response["owner_id"].stringValue
            ])
          deleteReq.isAsynchronous = false
          deleteReq.send()
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
          readyExpectation.fulfill()
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Audio path is empty")
    }
  }
  
  
  func test_upload_video_from_file() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testVideo", ofType: "mp4")!) {
      let media = Media(videoData: data)
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.video(
        media: media,
        link: nil,
        name: "test video",
        description: "test",
        groupId: nil,
        albumId: nil,
        isPrivate: true,
        isWallPost: false,
        isRepeat: false,
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          let deleteReq = VK.API.Audio.delete([
            VK.Arg.audioId : response["id"].stringValue,
            VK.Arg.ownerId : response["owner_id"].stringValue
            ])
          deleteReq.isAsynchronous = false
          deleteReq.send()
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
          readyExpectation.fulfill()
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Video path is empty")
    }
  }
  
  
  
  
  func test_upload_video_from_link() {
    VK.defaults.logOptions = [.upload]
    let readyExpectation = expectationWithDescription("ready")
    
    VK.API.Upload.video(
      media: nil,
      link: "http://www.youtube.com/watch?v=w7VD1681jV8",
      name: "test video",
      description: "test",
      groupId: nil,
      albumId: nil,
      isPrivate: true,
      isWallPost: false,
      isRepeat: false,
      isAsynchronous: true,
      progressBlock: {done, total in},
      successBlock: {response in
        let deleteReq = VK.API.Audio.delete([
          VK.Arg.audioId : response["id"].stringValue,
          VK.Arg.ownerId : response["owner_id"].stringValue
          ])
        deleteReq.isAsynchronous = false
        deleteReq.send()
        printSync("success request \(response)")
        readyExpectation.fulfill()
      },
      errorBlock: {error in
        XCTFail("Error request \(error)")
        readyExpectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(60, handler: { error in
      XCTAssertNil(error, "Timeout error")
    })
  }
  
  
  
  
  func test_upload_document() {
    VK.defaults.logOptions = [.upload]
    
    if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("testDoc", ofType: "rtf")!) {
      let media = Media(documentData: data, type: "rtf")
      let readyExpectation = expectationWithDescription("ready")
      
      VK.API.Upload.document(
        media: media,
        groupId: nil,
        title: "test",
        tags: nil,
        isAsynchronous: true,
        progressBlock: {done, total in},
        successBlock: {response in
          let deleteReq = VK.API.Audio.delete([
            VK.Arg.audioId : response["id"].stringValue,
            VK.Arg.ownerId : response["owner_id"].stringValue
            ])
          deleteReq.isAsynchronous = false
          deleteReq.send()
          printSync("success request \(response)")
          readyExpectation.fulfill()
        },
        errorBlock: {error in
          XCTFail("Error request \(error)")
          readyExpectation.fulfill()
      })
      
      waitForExpectationsWithTimeout(60, handler: { error in
        XCTAssertNil(error, "Timeout error")
      })
    }
    else {
      XCTFail("Document path is empty")
    }
  }
}
