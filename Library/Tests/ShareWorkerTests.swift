import Foundation
import XCTest
@testable import SwiftyVK

final class ShareWorkerTests: XCTestCase {
    
    override func tearDown() {
        VKStack.removeAllMocks()
    }
    
    func test_getPrefrences_parseAll_whenGivenFromApi() {
        wait({
            // Given
            let worker = ShareWorkerImpl()
            let method = VK.API.Users.get([.fields: "exports"])
            VKStack.mock(method, fileName: "users.get.success.withExports")
            // When
            let _preferences = try? worker.getPrefrences(in: VK.sessions.default)
            // Then
            guard let preferences = _preferences else {
                return XCTFail("Preferences is nil")
            }
            
            XCTAssertEqual(preferences.count, 4)
            XCTAssertEqual(preferences[0].key, "friendsOnly")
            XCTAssertEqual(preferences[0].active, false)
            
            XCTAssertEqual(preferences[1].key, "twitter")
            XCTAssertEqual(preferences[1].active, true)
            
            XCTAssertEqual(preferences[2].key, "facebook")
            XCTAssertEqual(preferences[2].active, true)
            
            XCTAssertEqual(preferences[3].key, "livejournal")
            XCTAssertEqual(preferences[3].active, true)
        })
    }
    
    func test_getPrefrences_notParse_whenNotGivenFromApi() {
        wait({
            // Given
            let worker = ShareWorkerImpl()
            let method = VK.API.Users.get([.fields: "exports"])
            VKStack.mock(method, fileName: "users.get.success.withoutExports")
            // When
            let _preferences = try? worker.getPrefrences(in: VK.sessions.default)
            // Then
            guard let preferences = _preferences else {
                return XCTFail("Preferences is nil")
            }
            
            XCTAssertEqual(preferences.count, 1)
            XCTAssertEqual(preferences[0].key, "friendsOnly")
            XCTAssertEqual(preferences[0].active, false)
        })
    }
    
    func test_uploadImage_addedToAttachements_whenImageUploaded() {
        // Given
        let exp = expectation(description: "")
        let worker = ShareWorkerImpl()
        let image = ShareImage(data: Data(), type: .jpg)

        VKStack.mock(
            VK.API.Photos.getWallUploadServer([.userId: ""]),
            fileName: "upload.getServer.success"
        )
        
        VKStack.mock(
            .upload(url: "https://test.vk.com", media: [.image(data: image.data, type: image.type)], partType: .photo),
            fileName: "upload.photos.toWall.success"
        )
        
        VKStack.mock(
            VK.API.Photos.saveWallPhoto([.userId: "", .hash: "testHash", .server: "999", .photo: "testPhoto"]),
            fileName: "upload.photos.saveWallPhoto.success"
        )
        
        image.setOnUpload {
            exp.fulfill()
        }
        
        image.setOnFail {
            XCTFail("Image should be uploaded")
            exp.fulfill()
        }
        // When
        worker.upload(images: [image], in: VK.sessions.default)
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(image.id, "photo101_100")
    }
    
    func test_uploadImage_notAddedToAttachements_whenImageNotUploaded() {
        // Given
        let exp = expectation(description: "")
        let worker = ShareWorkerImpl()
        let image = ShareImage(data: Data(), type: .jpg)
        
        VKStack.mock(
            VK.API.Photos.getWallUploadServer([.userId: ""]),
            error: .unexpectedResponse
        )
        
        image.setOnUpload {
            XCTFail("Image should be not uploaded")
            exp.fulfill()
        }
        
        image.setOnFail {
            exp.fulfill()
        }
        // When
        worker.upload(images: [image], in: VK.sessions.default)
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertNil(image.id)
    }
    
    func test_post_parameters_whenAllFilled() {
        // Given
        let worker = ShareWorkerImpl()
        let message = "TestText"
        let images = [ShareImage(data: Data(), type: .jpg), ShareImage(data: Data(), type: .jpg)]
        let shareLink = ShareLink(title: "TestLink", url: URL(string: "test.test")!)
        let services = "twitter,facebook,liveJournal"
        
        images[0].id = "011"
        images[1].id = "110"
        
        var context = ShareContext(
            text: message,
            images: images,
            link: shareLink
        )
        
        context.preferences = [
            ShareContextPreference(key: "twitter", name: "", active: true),
            ShareContextPreference(key: "facebook", name: "", active: true),
            ShareContextPreference(key: "liveJournal", name: "", active: true)

        ]
        
        VKStack.mock(
            VK.API.Wall.post([
                .message: message,
                .friendsOnly: "0",
                .services: services,
                .attachments: images.compactMap { $0.id }.joined(separator: ",") + "," + shareLink.url.absoluteString
                ]),
            data: Data()
        )

        // When
        wait({
            do {
                let data = try worker.post(context: context, in: VK.sessions.default)
                // Then
                XCTAssertEqual(data, Data())
            }
            catch {
                XCTFail("unexpected error: \(error)")
            }
        })
    }
    
    func test_post_parameters_whenOnlyLinkSetted() {
        // Given
        let worker = ShareWorkerImpl()
        let shareLink = ShareLink(title: "TestLink", url: URL(string: "test.test")!)
        
        let context = ShareContext(
            link: shareLink
        )
        
        VKStack.mock(
            VK.API.Wall.post([
                .message: shareLink.title,
                .friendsOnly: "0",
                .services: "",
                .attachments: shareLink.url.absoluteString
                ]),
            data: Data()
        )
        
        // When
        wait({
            do {
                let data = try worker.post(context: context, in: VK.sessions.default)
                // Then
                XCTAssertEqual(data, Data())
            }
            catch {
                XCTFail("unexpected error: \(error)")
            }
        })
    }
    
    private func wait(_ clousure: @escaping () -> (), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "")
        
        DispatchQueue.global().async {
            clousure()
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
