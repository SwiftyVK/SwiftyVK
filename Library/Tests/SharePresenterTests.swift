import Foundation
import XCTest
@testable import SwiftyVK

final class SharePresenterTests: XCTestCase {
    
    func test_share_allFlowSteps_isCalled() {
        // Given
        VKStack.mockSession()
        let context = makeContext()
        let group = DispatchGroup()
    
        context.controllerMaker.onMake = { onDismiss in
            group.leave()
            context.controller.onDismiss = onDismiss
            return context.controller
        }
        group.enter()
        
        context.controller.onShowWaitForConnection = {
            group.leave()
            context.controller.onDismiss?()
        }
        group.enter()
        
        context.controller.onShare = { shareContext, onPost in
            group.leave()
            onPost(shareContext)
        }
        group.enter()

        context.controller.onClose = {
            group.leave()
        }
        group.enter()

        context.controller.onEnablePostButton = { _ in
            group.leave()
        }
        group.enter()

        context.controller.onShowPlaceholder = {
            group.leave()
        }
        group.enter()

        context.shareWorker.onPost = { _, _ in
            group.leave()
            return Data()
        }
        group.enter()

        context.shareWorker.onUpload = { _, _ in
            group.leave()
        }
        group.enter()

        context.shareWorker.onGetPrefrences = { _ in
            group.leave()
            return []
        }
        group.enter()

        context.reachability.onWaitForReachable = { onWait in
            group.leave()
            onWait()
        }
        group.enter()

        // When
        do {
            let data = try context.presenter.share(ShareContext(), in: VK.sessions.default)
            XCTAssertEqual(data, Data())
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }        // Then
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
    }
    
    func test_share_showError_isCalled() {
        // Given
        VKStack.mockSession()
        let context = makeContext()
        let group = DispatchGroup()
        
        context.controllerMaker.onMake = { onDismiss in
            context.controller.onDismiss = onDismiss
            return context.controller
        }
        
        context.controller.onShare = { shareContext, onPost in
            onPost(shareContext)
        }
                
        context.shareWorker.onPost = { _, _ in
            throw VKError.unexpectedResponse
        }
        
        context.controller.onShowError = { _, _, _ in
            group.leave()
            context.controller.close()
        }
        group.enter()
        
        context.controller.onEnablePostButton = { enable in
            if enable {
                group.leave()
            }
        }
        group.enter()
        
        // When
        do {
            _ = try context.presenter.share(ShareContext(), in: VK.sessions.default)
            XCTFail("Expression should throw error")
        }
        catch {
            XCTAssertEqual(error.toVK(), .unexpectedResponse)
        }
        // Then
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
    }
}

private func makeContext() -> (
    presenter: SharePresenterImpl,
    controller: ShareControllerMock,
    controllerMaker: ShareControllerMakerMock,
    shareWorker: ShareWorkerMock,
    reachability: VKReachabilityMock
    ) {
        let controllerMaker = ShareControllerMakerMock()
        let shareWorker = ShareWorkerMock()
        let reachability = VKReachabilityMock()
        let controller = ShareControllerMock()
        
        let presenter = SharePresenterImpl(
            uiSyncQueue: DispatchQueue.global(),
            shareWorker: shareWorker,
            controllerMaker: controllerMaker,
            reachability: reachability
        )
        
        return (presenter, controller, controllerMaker, shareWorker, reachability)
}
