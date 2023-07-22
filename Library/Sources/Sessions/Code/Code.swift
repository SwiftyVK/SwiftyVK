//
//  Code.swift
//  SwiftyVK_macOS
//
//  Created by PeterSamokhin on 30.03.2020.
//

import Foundation

public protocol Code: class {
    var info: [String: String] { get }
    
    func get() -> String?
}

final class CodeImpl: NSObject, Code {
    
    private let code: String
    let info: [String: String]
    
    init(
        code: String,
        info: [String: String]
    ) {
        self.code = code
        self.info = info
    }
    
    func get() -> String? {
        return code
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: "code")
        aCoder.encode(info, forKey: "info")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let code = aDecoder.decodeObject(forKey: "code") as? String,
            let info = aDecoder.decodeObject(forKey: "info") as? [String: String] else {
                return nil
        }
        
        self.code = code
        self.info = info
    }
}
