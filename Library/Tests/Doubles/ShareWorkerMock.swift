@testable import SwiftyVK
import XCTest

final class ShareWorkerMock: ShareWorker {
    
    func add(link: ShareLink?) {
    }
    
    func upload(images: [ShareImage], in session: Session) {
    }
    
    func getPrefrences(in session: Session) throws -> [ShareContextPreference] {
        return []
    }
    
    func post(context: ShareContext, in session: Session) throws -> Data? {
        return nil
    }
    
    func clear(context: ShareContext) {
    }
}
