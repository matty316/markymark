//
//  Emitter.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/14/24.
//

import Foundation

struct Emitter {
    static func emitHtml(_ content: Content) -> String {
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
}
