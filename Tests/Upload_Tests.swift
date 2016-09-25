import XCTest
@testable import SwiftyVK



class Upload_Tests: VKTestCase {
    
    func test_photo_to_message() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "testImage", ofType: "jpg")!)) else {
            XCTFail("Image path is empty")
            return
        }
        
        Stubs.apiWith(method: "photos.getMessagesUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadPhoto", dataSize: 158043)
        Stubs.apiWith(
            method: "photos.saveMessagesPhoto",
            params: ["server"   : "626627",
                     "photo"    : "TESTINFO",
                     "hash"     : "581d7a4ffc81e2bfe90016d8b35c288d"],
            jsonFile: "success.savePhoto"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Photo.toMessage(Media(imageData: data, type: .JPG))
        req.asynchronous = true
        req.progressBlock = {done, total in}
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.progressBlock = {_,_ in progressExecuted = true}
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_photo_to_group_wall() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testImage", ofType: "jpg")!)) else {
            XCTFail("Image path is empty")
            return
        }
        
        Stubs.apiWith(method: "photos.getWallUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadPhoto", dataSize: 158043)
        Stubs.apiWith(
            method: "photos.saveWallPhoto",
            params: ["server"   :"626627",
                     "photo"    :"TESTINFO",
                     "hash"     :"581d7a4ffc81e2bfe90016d8b35c288d"],
            jsonFile: "success.savePhoto"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Photo.toWall.toGroup(
            Media(imageData: data, type: .JPG),
            groupId: "60479154")
        req.asynchronous = true
        req.progressBlock = {done, total in}
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_photo_to_album() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testImage", ofType: "jpg")!)) else {
            XCTFail("Image path is empty")
            return
        }
        
        Stubs.apiWith(method: "photos.getUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadPhotosToAlbum", dataSize: 158043)
        Stubs.apiWith(
            method: "photos.save",
            params: ["server"       :"626627",
                     "photos_list"  :"TESTINFO",
                     "aid"          :"98754321",
                     "hash"         :"581d7a4ffc81e2bfe90016d8b35c288d"],
            jsonFile: "success.savePhoto"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Photo.toAlbum(
            [Media(imageData: data, type: .JPG)],
            albumId: "181808365",
            groupId: "60479154",
            caption: "test")
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            let deleteReq = VK.API.Photos.delete([VK.Arg.photoId : response[0]["id"].stringValue])
            deleteReq.asynchronous = true
            runInCI() ? () : deleteReq.send()
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_photo_to_market() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testImage", ofType: "jpg")!)) else {
            XCTFail("Image path is empty")
            return
        }
        
        Stubs.apiWith(method: "photos.getMarketUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadMarketPhoto", dataSize: 158043)
        Stubs.apiWith(
            method: "photos.saveMarketPhoto",
            params: ["server"   :"626627",
                     "photo"    :"TESTINFO",
                     "hash"     :"581d7a4ffc81e2bfe90016d8b35c288d",
                     "crop_data":"oAAmMpwAAAAAlTWyjA",
                     "crop_hash":"729155760247b391134"],
            jsonFile: "success.savePhoto"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Photo.toMarket(
            Media(imageData: data, type: .JPG),
            groupId: "98197515"
        )
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_photo_to_market_album() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testImage", ofType: "jpg")!)) else {
            XCTFail("Image path is empty")
            return
        }
        
        Stubs.apiWith(method: "photos.getMarketAlbumUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadMarketAlbumPhoto", dataSize: 158043)
        Stubs.apiWith(
            method: "photos.saveMarketAlbumPhoto",
            params: ["server"   :"626627",
                     "photo"    :"TESTINFO",
                     "hash"     :"581d7a4ffc81e2bfe90016d8b35c288d",
                     "group_id" :"98197515"
            ],
            jsonFile: "success.savePhoto"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Photo.toMarketAlbum(
            Media(imageData: data, type: .JPG),
            groupId: "98197515"
        )
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_audio() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testAudio", ofType: "mp3")!)) else {
            XCTFail("Audio path is empty")
            return
        }
        
        Stubs.apiWith(method: "audio.getUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadAudio", dataSize: 5074416)
        Stubs.apiWith(
            method: "audio.save",
            params: ["server":"626627",
                     "hash":"581d7a4ffc81e2bfe90016d8b35c288d",
                     "audio":"TESTAUDIO"
            ],
            jsonFile: "success.saveAudio"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.audio(Media(audioData: data))
        req.logToConsole = true
        
        req.asynchronous = true
        req.progressBlock = {done, total in}
        req.successBlock = {response in
            XCTAssertNotNil(response["id"].int)
            let deleteReq = VK.API.Audio.delete([
                VK.Arg.audioId : response["id"].stringValue,
                VK.Arg.ownerId : response["owner_id"].stringValue
                ])
            deleteReq.asynchronous = false
            runInCI() ? () : deleteReq.send()
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    func test_video_file() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testVideo", ofType: "mp4")!)) else {
            XCTFail("Video path is empty")
            return
        }
        
        Stubs.apiWith(method: "video.save", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadVideo", dataSize: 3120019)
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Video.fromFile(
            Media(videoData: data),
            name: "test video",
            description: "test",
            isPrivate: true,
            isWallPost: false,
            isRepeat: false)
        req.asynchronous = true
        req.successBlock = {response in
            XCTAssertNotNil(response["video_id"].int)
            let deleteReq = VK.API.Audio.delete([
                VK.Arg.audioId : response["video_id"].stringValue,
                VK.Arg.ownerId : response["owner_id"].stringValue
                ])
            deleteReq.asynchronous = false
            runInCI() ? () : deleteReq.send()
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    
    func test_video_link() {
        Stubs.apiWith(method: "video.save", jsonFile: "success.uploadVideo")

        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.Video.fromUrl(
            "http://www.youtube.com/watch?v=w7VD1681jV8",
            name: "test video",
            description: "test",
            isPrivate: true,
            isWallPost: false,
            isRepeat: false)
        req.asynchronous = true
        req.successBlock = {response in
            XCTAssertNotNil(response["video_id"].int)
            let deleteReq = VK.API.Audio.delete([
                VK.Arg.audioId : response["video_id"].stringValue,
                VK.Arg.ownerId : response["owner_id"].stringValue
                ])
            deleteReq.asynchronous = false
            runInCI() ? () : deleteReq.send()
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
    
    
    
    
    func test_document() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource:"testDoc", ofType: "rtf")!)) else {
            XCTFail("Document path is empty")
            return
        }
        
        Stubs.apiWith(method: "docs.getUploadServer", jsonFile: "success.getUploadServer")
        Stubs.uploadServerWith(jsonFile: "success.uploadDocument", dataSize: 950)
        Stubs.apiWith(
            method: "docs.save",
            params: ["file":"TESTDOC"],
            jsonFile: "success.saveDocument"
        )
        
        let exp = expectation(description: "ready")
        var progressExecuted = false || runInCI()
        
        let req = VK.API.Upload.document(Media(documentData: data, type: "rtf"))
        req.asynchronous = true
        req.progressBlock = {done, total in}
        req.successBlock = {response in
            XCTAssertNotNil(response[0,"id"].int)
            let deleteReq = VK.API.Audio.delete([
                VK.Arg.audioId : response["id"].stringValue,
                VK.Arg.ownerId : response["owner_id"].stringValue
                ])
            deleteReq.asynchronous = false
            runInCI() ? () : deleteReq.send()
            exp.fulfill()
        }
        req.errorBlock = {error in
            XCTFail("Unexpected error in request: \(error)")
            exp.fulfill()
        }
        req.send()
        
        waitForExpectations(timeout: reqTimeout*10) {_ in
            XCTAssertTrue(progressExecuted)
        }
    }
}
