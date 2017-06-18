import Foundation
import XCTest
@testable import SwiftyVK

class CaptchaPresenterTests: XCTestCase {
    
    func makeContext() -> (presenter: CaptchaPresenter, webControllerMaker: CaptchaControllerMakerMock) {
        let controllerMaker = CaptchaControllerMakerMock()
        
        let presenter = CaptchaPresenterImpl(
            uiSyncQueue: DispatchQueue.global(),
            controllerMaker: controllerMaker,
            timeout: 1
        )
        return (presenter, controllerMaker)
    }
    
}
