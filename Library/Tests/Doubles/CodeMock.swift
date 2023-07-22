//
//  CodeMock.swift
//  SwiftyVK
//
//  Created by PeterSamokhin on 30.03.2020.
//

@testable import SwiftyVK

final class CodeMock: NSObject, Code {
    
    var code: String?
    let info: [String: String] = [:]
    
    init(code: String = "testToken") {
        self.code = code
    }
    
    init?(coder aDecoder: NSCoder) {
        code = aDecoder.decodeObject(forKey: "code") as? String ?? ""
    }
    
    func get() -> String? {
        return code
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: "code")
    }
}
