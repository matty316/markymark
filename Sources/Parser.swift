//
//  Parser.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

enum ParserError: Error {
    case invalidToken
}

struct Parser {
    let tokens: [Token]
    var position = 0
    var isAtEnd: Bool {
        current.type == .eof
    }
    var prev: Token {
        tokens[position - 1]
    }
    var current: Token {
        return tokens[position]
    }
    
    mutating func parse() throws(ParserError) -> Markup {
        var elements = [Element]()
        
        let frontMatter = try parseFrontMatter()
        
        while !isAtEnd {
            elements.append(try parseElement())
        }
        return Markup(elements: elements, frontMatter: frontMatter)
    }
    
    mutating func parseFrontMatter() throws(ParserError) -> [String: String] {
        guard match([.minus3]) else {
            return [:]
        }
        try expect([.lineEnding])

        var frontMatter = [String: String]()
        while current.type != .minus3 {
            let text = current.string.split(separator: ":")
            let key = String(text[0])
            let val = String(text[1]).trimmingCharacters(in: .whitespaces)
            frontMatter[key] = val
            advance()
            try expect([.lineEnding])
        }
        return frontMatter
    }
    
    mutating func parseElement() throws(ParserError) -> Element {
        if match([.star, .plus, .minus]) { return try parseList() }
        return try parseLine()
    }
    
    mutating func parseList() throws(ParserError) -> Element {
        Line(lineType: .h1, content: "")
    }
    
    mutating func parseLine() throws(ParserError) -> Line {
        if match([.lineEnding]) { return Line(lineType: .blank, content: "") }
        if match([.hash, .hash2, .hash3, .hash4, .hash5, .hash6]) { return try parseHeader() }
        return try parseParagraph()
    }
    
    mutating func parseHeader() throws(ParserError) -> Line {
        let type = prev.type
        let text = current.string
        advance()
        try expect([.lineEnding, .eof])
        
        return switch type {
        case .hash: Line(lineType: .h1, content: text)
        case .hash2: Line(lineType: .h2, content: text)
        case .hash3: Line(lineType: .h3, content: text)
        case .hash4: Line(lineType: .h4, content: text)
        case .hash5: Line(lineType: .h5, content: text)
        case .hash6: Line(lineType: .h6, content: text)
        default: try parseParagraph()
        }
    }
    
    mutating func parseParagraph() throws(ParserError) -> Line {
        let text = current.string
        advance()
        try expect([.lineEnding, .eof])
        return Line(lineType: .p, content: text)
    }
    
    mutating func advance() {
        if isAtEnd {
            return
        }
        position += 1
    }
    
    mutating func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if current.type == type {
                advance()
                return true
            }
        }
        return false
    }
    
    mutating func expect(_ types: [TokenType]) throws(ParserError) {
        if match(types) {
            return
        }
        throw .invalidToken
    }
}
