@testable import SwiftyVK
import XCTest

final class ShareWorkerMock: ShareWorker {
    
    var onUpload: (([ShareImage], Session) -> ())?
    
    func upload(images: [ShareImage], in session: Session) {
        onUpload?(images, session)
    }
    
    var onGetPrefrences: ((Session) throws -> [ShareContextPreference])?
    
    func getPrefrences(in session: Session) throws -> [ShareContextPreference] {
        return try onGetPrefrences?(session) ?? []
    }
    
    var onPost: ((ShareContext, Session) throws -> Data)?
    
    func post(context: ShareContext, in session: Session) throws -> Data? {
        return try onPost?(context, session)
    }
    
    var onClear: ((ShareContext) -> ())?
    
    func clear(context: ShareContext) {
        onClear?(context)
    }
}
