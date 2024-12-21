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
        
        while current.type == .lineEnding {
            advance()
        }
        
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
        try expect([.minus3])
        return frontMatter
    }
    
    mutating func parseElement() throws(ParserError) -> Element {
        if match([.star, .plus, .minus]) { return try parseUnorderedList() }
        if match([.gt]) { return try parseBlockQuote() }
        if match([.tick3]) { return try parseCodeBlock() }
        if match([.minus3, .underscore3, .star3]) { return Line(lineType: .hr, content: Content(string: ""))}
        if match([.num]) { return try parseOrderedList() }
        if match([.bang]) { return try parseImg() }
        if match([.lbracket]) { return try parseLink() }
        return try parseLine()
    }
    
    mutating func parseUnorderedList() throws(ParserError) -> Element {
        var lineItems = [Line]()
        while true {
            let text = current.string
            advance()
            lineItems.append(Line(lineType: .unorderedListItem, content: Content(string: text)))
            try expect([.lineEnding, .eof])
            if !match([.plus, .star, .minus]) {
                break
            }
        }
        return List(lines: lineItems, ordered: false)
    }
    
    mutating func parseOrderedList() throws(ParserError) -> Element {
        var lineItems = [Line]()
        while true {
            let text = current.string
            advance()
            lineItems.append(Line(lineType: .orderedListItem, content: Content(string: text)))
            try expect([.lineEnding, .eof])
            if !match([.num]) {
                break
            }
        }
        return List(lines: lineItems, ordered: true)
    }
    
    mutating func parseBlockQuote() throws(ParserError) -> Element {
        var lines = [Line]()
        while true {
            let line = try parseLine()
            lines.append(line)
            if !match([.gt]) {
                break
            }
        }
        try expect([.lineEnding, .eof])
        return BlockQuote(lines: lines)
    }
    
    mutating func parseCodeBlock() throws(ParserError) -> Element {
        let text = current.string
        advance()
        try expect([.tick3])
        try expect([.lineEnding, .eof])
        return CodeBlock(text: text)
    }
    
    mutating func parseLink() throws(ParserError) -> Element {
        if match([.lineEnding, .eof]) {
            return Line(lineType: .p, content: Content(string: "["))
        }
        let text = "[\(current.string)"
        advance()
        return Line(lineType: .p, content: Content(string: text))
    }
    
    mutating func parseImg() throws(ParserError) -> Element {
        guard match([.lbracket]) else {
            let text = current.string
            advance()
            return Line(lineType: .p, content: Content(string: "!\(text)"))
        }
        let string = current.string
        guard let rbracket = string.range(of: "]"),
              let lparen = string.range(of: "("),
              let rparen = string.range(of: ")") else {
            let text = current.string
            advance()
            return Line(lineType: .p, content: Content(string: "![\(text)"))
        }
        
        let alt = String(string[..<rbracket.lowerBound])
        let src = String(string[lparen.upperBound..<rparen.lowerBound])
        advance()
        try expect([.lineEnding, .eof])
        
        return Img(alt: alt, src: src)
    }
    
    mutating func parseLine() throws(ParserError) -> Line {
        if match([.lineEnding]) { return Line(lineType: .blank, content: Content(string: "")) }
        if match([.hash, .hash2, .hash3, .hash4, .hash5, .hash6]) { return try parseHeader() }
        return try parseParagraph()
    }
    
    mutating func parseHeader() throws(ParserError) -> Line {
        let type = prev.type
        let text = current.string
        advance()
        try expect([.lineEnding, .eof])
        
        return switch type {
        case .hash: Line(lineType: .h1, content: Content(string: text))
        case .hash2: Line(lineType: .h2, content: Content(string: text))
        case .hash3: Line(lineType: .h3, content: Content(string: text))
        case .hash4: Line(lineType: .h4, content: Content(string: text))
        case .hash5: Line(lineType: .h5, content: Content(string: text))
        case .hash6: Line(lineType: .h6, content: Content(string: text))
        default: try parseParagraph()
        }
    }
    
    mutating func parseParagraph() throws(ParserError) -> Line {
        let text = current.string
        advance()
        try expect([.lineEnding, .eof])
        return Line(lineType: .p, content: Content(string: text))
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
