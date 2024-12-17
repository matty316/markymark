//
//  Emitter.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/14/24.
//

import Foundation

enum EmmiterError: Error {
    case unterminatedLink
}

struct Emitter {
    static func emitHtml(_ content: Content) throws(EmmiterError) -> String {
        var string = content.string
        
        string = replace(string, "***", with: "<em><strong>", and: "</strong></em>")
        string = replace(string, "+++", with: "<em><strong>", and: "</strong></em>")
        string = replace(string, "___", with: "<em><strong>", and: "</strong></em>")
        string = replace(string, "**", with: "<strong>", and: "</strong>")
        string = replace(string, "++", with: "<strong>", and: "</strong>")
        string = replace(string, "__", with: "<strong>", and: "</strong>")
        string = replace(string, "*", with: "<em>", and: "</em>")
        string = replace(string, "+", with: "<em>", and: "</em>")
        string = replace(string, "_", with: "<em>", and: "</em>")
        string = replace(string, "`", with: "<code>", and: "</code>")
        
        string = try replaceLinks(string)
        
        return string
    }
    
    static func replace(_ string: String, _ pattern: String, with opening: String, and closing: String) -> String {
        var newString = string
        var openingElement = true
        while let range = newString.range(of: pattern) {
            newString = newString.replacingCharacters(in: range, with: openingElement ? opening : closing )
            openingElement.toggle()
        }
        return newString
    }
    
    static func replaceLinks(_ string: String) throws(EmmiterError) -> String {
        var newString = string
        while let lBracket = newString.range(of: "[") {
            guard let rBracket = newString[lBracket.upperBound...].range(of: "]") else {
                throw .unterminatedLink
            }
            
            guard let lParen = newString[rBracket.upperBound...].range(of: "("),
                    let rParen = newString[lParen.upperBound...].range(of: ")") else {
                throw .unterminatedLink
            }
            
            let pattern = newString[lBracket.lowerBound..<rParen.upperBound]
            let title = newString[lBracket.upperBound..<rBracket.lowerBound]
            let href = newString[lParen.upperBound..<rParen.lowerBound]
            let newPattern = "<a href=\"\(href)\">\(title)</a>"
            newString = newString.replacingOccurrences(of: pattern, with: newPattern)
        }
        return newString
    }
}
