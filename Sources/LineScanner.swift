//
//  LineScanner.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/14/24.
//

import Foundation

enum LineScannerError: Error {
    case unterminatedLink
    case mismatchedSymbols(Character)
    case unreachable
}

struct LineScanner {
    var insideLink = false
    var string: String
    var linkRanges = [Range<String.Index>]()
    var pos: String.Index
    var start: String.Index
    
    var isAtLineEnding: Bool {
        peek == "\n" || peek == "\r" || peek == "\r\n" || peek == "\0"
    }
    
    static func text(content: Content) throws -> String {
        var ls = LineScanner(content: content)
        let tokens = try ls.scan()
        return try ls.replace(tokens: tokens)
    }

    var isAtEnd: Bool {
        pos >= string.endIndex
    }
    
    var peek: Character {
        if isAtEnd { return "\0" }
        return string[pos]
    }
    
    var current: Character {
        if pos == string.startIndex {
            return string[string.startIndex]
        }
        return string[string.index(before: pos)]
    }

    init(content: Content) {
        self.string = content.string
        self.pos = content.string.startIndex
        self.start = content.string.startIndex
    }
    
    mutating func scan() throws(LineScannerError) -> [Token] {
        var tokens = [Token]()
        while !isAtEnd {
            start = pos
            let c = advance()
            let newTokens = switch c {
            case "*": [try readEmphasis("*")]
            case "_": [try readEmphasis("_")]
            case "[": try readLink()
            case "`": [Token(type: .tick)]
            default: [try readText()]
            }
            tokens.append(contentsOf: newTokens)
        }
        return tokens
    }
    
    mutating func replace(tokens: [Token]) throws -> String {
        var string = ""
        var opening = true
        var pos = 0
        while pos < tokens.count {
            let token = tokens[pos]
            switch token.type {
            case .star, .underscore:
                string.append(opening ? "<em>" : "</em>")
                opening.toggle()
            case .star2, .underscore2:
                string.append(opening ? "<strong>" : "</strong>")
                opening.toggle()
            case .star3, .underscore3:
                string.append(opening ? "<em><strong>" : "</strong></em>")
                opening.toggle()
            case .tick:
                string.append(opening ? "<code>" : "</code>")
                opening.toggle()
            case .lbracket:
                pos += 1
                let text = tokens[pos].string
                pos += 3
                let link = tokens[pos].string
                pos += 1
                string.append("<a href=\"\(link)\">\(text)</a>")
            case .text: string.append(token.string)
            default: break
            }
            pos += 1
        }
        return string
    }
    
    func isStoppingToken() -> Bool {
        peek == "*" ||
        peek == "_" ||
        peek == "[" ||
        peek == "`" ||
        peek == "\n" ||
        peek == "\r" ||
        peek == "\r\n" ||
        peek == "\0"
    }
    
    mutating func readText() throws(LineScannerError) -> Token {
        while !isStoppingToken() || current == "\\" {
            advance()
        }
        
        let text = String(string[start..<pos])
            .replacingOccurrences(of: "\\", with: "")
        return Token(string: text)
    }
    
    mutating func readLink() throws(LineScannerError) -> [Token] {
        while peek != "]" && !isAtLineEnding {
            advance()
        }
        
        let text = String(string[string.index(after: start)..<pos])
        if isAtLineEnding {
            return[Token(string: "[\(text)")]
        }
        advance()
        guard peek == "(" else {
            return [Token(string: "[\(text)]")]
        }
        advance()
        start = pos
        
        while peek != ")" && !isAtLineEnding  {
            advance()
        }
        
        
        let link = String(string[start..<pos])
        if isAtLineEnding {
            return[Token(string: "[\(text)](\(link)")]
        }
        
        advance()
        return [
            Token(type: .lbracket),
            Token(string: text),
            Token(type: .rbracket),
            Token(type: .lparen),
            Token(string: link),
            Token(type: .rparen)
        ]
    }
    
    mutating func readEmphasis(_ c: Character) throws(LineScannerError) -> Token {
        var count = 1
        while peek == c {
            advance()
            count += 1
        }
        
        if count <= 3 {
            return try getEmphasisToken(c, count)
        }
        return try readText()
    }
    
    mutating func getEmphasisToken(_ c: Character, _ count: Int) throws(LineScannerError) -> Token {
        switch c {
        case "*":
            return switch count {
            case 1: Token(type: .star)
            case 2: Token(type: .star2)
            case 3: Token(type: .star3)
            default: throw .unreachable
            }
        case "_":
            return switch count {
            case 1: Token(type: .underscore)
            case 2: Token(type: .underscore2)
            case 3: Token(type: .underscore3)
            default: throw .unreachable
            }
        default: throw .unreachable
        }
    }
    
    @discardableResult
    mutating func advance() -> Character {
        if isAtEnd { return "\0" }
        let prev = pos
        pos = string.index(after: pos)
        return string[prev]
    }
}
