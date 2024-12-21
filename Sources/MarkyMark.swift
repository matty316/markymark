//
//  MarkyMark.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/12/24.
//

import Foundation
import AppKit

enum MarkyMarkError: Error {
    case invalidHTML
}

public struct MarkyMark {
    public static func parse(_ input: String) throws -> Markup {
        var scanner = Scanner(input: input)
        let tokens = try scanner.scan()
        var parser = Parser(tokens: tokens)
        return try parser.parse()
    }
    
    public static func html(_ input: String) throws -> String {
        let markup = try parse(input)
        return try markup.html()
    }
    
    public static func attributedString(_ input: String) throws -> AttributedString {
        var html = try html(input)
        guard let data = html.data(using: .utf8) else {
            throw MarkyMarkError.invalidHTML
        }
        let nsAttributerString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        return AttributedString(nsAttributerString)
    }
}

