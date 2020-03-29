//
//  CodeParser.swift
//  SwiftyVK_macOS
//
//  Created by PeterSamokhin on 30.03.2020.
//

import Foundation

protocol CodeParser: class {
    func parse(codeInfo: String) -> (code: String, info: [String: String])?
}

final class CodeParserImpl: CodeParser {
    
    func parse(codeInfo: String) -> (code: String, info: [String: String])? {
        var code: String?
        var info = [String: String]()
        
        let components = codeInfo.components(separatedBy: "&")
        
        components.forEach { component in
            let componentPair = component.components(separatedBy: "=")
            
            if let key = componentPair.first, let value = componentPair.last {
                
                switch key {
                case "code":
                    code = value
                default:
                    break
                }
                
                info[key] = value
            }
        }
        
        guard let unwrappedCode = code else {
            return nil
        }
        
        return (unwrappedCode, info)
    }
}
