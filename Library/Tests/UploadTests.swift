import Foundation
import XCTest
import CoreLocation
@testable import SwiftyVK

final class UploadTests: XCTestCase {
    
    override func tearDown() {
        VKStack.removeAllMocks()
    }
    
    func test_photo_toWall() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getWallUploadServer([.userId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .photo),
            fileName: "upload.photos.toWall.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveWallPhoto([.userId: "1", .hash: "testHash", .server: "999", .photo: "testPhoto"]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toWall(media, to: .user(id: "1"))
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toMain() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getOwnerPhotoUploadServer([.ownerId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com&_square_crop=10,20,30", media: [media], partType: .photo),
            fileName: "upload.photos.ownerPhoto.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveOwnerPhoto([.server: "999", .photo: "testPhoto", .hash: "testHash"]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toMain(media, to: .user(id: "1"), crop: (x: "10", y: "20", w: "30"))
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toAlbum() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getUploadServer([.albumId: "testAlbumId", .groupId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(
                url: "https://test.vk.com",
                media: [media],
                partType: .indexedFile
            ),
            fileName: "upload.photos.toAlbum.success"
        )
        
        VKStack.mock(
            VK.API.Photos.save([
                .groupId: "1",
                .albumId: "testAlbumId",
                .server: "999",
                .photosList: "testPhotosList",
                .hash: "testHash",
                .aid: "888",
                .latitude: "1.0",
                .longitude: "2.0",
                .caption: "testCaption"
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toAlbum(
            [media],
            to: .group(id: "1"),
            albumId: "testAlbumId",
            caption: "testCaption",
            location: CLLocationCoordinate2D(latitude: 1, longitude: 2)
            )
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toMessage() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getMessagesUploadServer([.peerId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .photo),
            fileName: "upload.photos.toWall.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveMessagesPhoto([.hash: "testHash", .server: "999", .photo: "testPhoto"]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toMessage(media, peerId: "1")
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toChatMain() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getChatUploadServer([
                .chatId: "1",
                .cropX: "10",
                .cropY: "20",
                .cropWidth: "30"
                ]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .file),
            fileName: "upload.photos.toChatMain.success"
        )
        
        VKStack.mock(
            VK.API.Messages.setChatPhoto([.file: "testResponse"]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toChatMain(media, to: 1, crop: (x: "10", y: "20", w: "30"))
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toMarket() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getMarketUploadServer([.groupId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .file),
            fileName: "upload.photos.toMarket.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveMarketPhoto([
                .groupId: "1",
                .photo: "testPhoto",
                .server: "999",
                .hash: "testHash",
                .cropData: "testCropData",
                .cropHash: "testCropHash",
                .mainPhoto: "1",
                .cropX: "10",
                .cropY: "20",
                .cropWidth: "30"
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toMarket(media, mainPhotoCrop: (x: "10", y: "20", w: "30"), groupId: "1")
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toMarketAlbum() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getMarketAlbumUploadServer([.groupId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .file),
            fileName: "upload.photos.toMarket.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveMarketAlbumPhoto([
                .groupId: "1",
                .photo: "testPhoto",
                .server: "999",
                .hash: "testHash",
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toMarketAlbum(media, groupId: "1")
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_audio() {
        // Given
        let exp = expectation(description: "")
        let media = Media.audio(data: Data())
        var response: JSON?
        
        VKStack.mock(
            VK.API.Audio.getUploadServer(.empty),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .file),
            fileName: "upload.audio.success"
        )
        
        VKStack.mock(
            VK.API.Audio.save([
                .audio: "testAudio",
                .server: "999",
                .hash: "testHash",
                .artist: "testArtist",
                .title: "testTitle"
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.audio(media, artist: "testArtist", title: "testTitle")
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_video() {
        // Given
        let exp = expectation(description: "")
        let media = Media.video(data: Data())
        var response: JSON?
        
        VKStack.mock(
            VK.API.Video.save([.name: "testName"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .video),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.video(media, savingParams: [.name: "testName"])
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    
    func test_document() {
        // Given
        let exp = expectation(description: "")
        let media = Media.document(data: Data(), type: "testType")
        var response: JSON?
        
        VKStack.mock(
            VK.API.Docs.getUploadServer([.groupId: "1"]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .file),
            fileName: "upload.document.success"
        )
        
        VKStack.mock(
            VK.API.Docs.save([
                .file: "testFile",
                .title: "testTitle",
                .tags: "testTags"
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.document(media, groupId: "1", title: "testTitle", tags: "testTags")
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
    
    func test_photo_toGroupCover() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getOwnerCoverPhotoUploadServer([
                .groupId: "1",
                .cropX: "10",
                .cropY: "20",
                .cropX2: "30",
                .cropY2: "40"
                ]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [media], partType: .photo),
            fileName: "upload.photos.toMarket.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveOwnerCoverPhoto([
                .photo: "testPhoto",
                .hash: "testHash",
                ]),
            fileName: "upload.save.success"
        )
        
        // When
        VK.API.Upload.Photo.toGroupCover(media, to: 1, crop: (x: "10", y: "20", x2: "30", y2: "40"))
            .onSuccess {
                response = try? JSON(data: $0)
                exp.fulfill()
            }
            .send()
        
        // Then
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(response?.bool("result") ?? false)
    }
}
