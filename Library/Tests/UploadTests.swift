import Foundation
import XCTest
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
            fileName: "photos.getWallUploadServer.success"
        )
        
        VKStack.mock(
            Request(type: .upload(url: "https://test.vk.com", media: [media], partType: .photo)).toMethod(),
            fileName: "photos.upload.toWall.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveWallPhoto([.userId: "1", .hash: "testHash", .server: "1234567890", .photo: "testPhoto"]),
            fileName: "photos.saveWallPhoto.success"
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
        
        XCTAssertEqual(response?.int("0,id"), 100)
    }
    
    func test_photo_toMain() {
        // Given
        let exp = expectation(description: "")
        let media = Media.image(data: Data(), type: .jpg)
        var response: JSON?
        
        VKStack.mock(
            VK.API.Photos.getOwnerPhotoUploadServer([.ownerId: "1"]),
            fileName: "photos.getOwnerPhotoUploadServer.success"
        )
        
        VKStack.mock(
            Request(type: .upload(url: "https://test.vk.com/page&_square_crop=10,20,30", media: [media], partType: .photo)).toMethod(),
            fileName: "photos.uploadOwnerPhoto.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveOwnerPhoto([.server: "999", .photo: "testPhoto", .hash: "testHash"]),
            fileName: "photos.saveOwnerPhoto.success"
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
        
        XCTAssertEqual(response?.int("0,id"), 100)
    }
}
