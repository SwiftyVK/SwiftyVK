//
//  CodeParserMock.swift
//  SwiftyVK_macOS
//
//  Created by PeterSamokhin on 30.03.2020.
//

@testable import SwiftyVK

final class CodeParserMock: CodeParser {
    
    var onParse: ((String) -> (code: String, info: [String : String])?)?
    
    func parse(codeInfo: String) -> (code: String, info: [String : String])? {
        return onParse?(codeInfo)
    }
}
