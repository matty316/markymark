//
//  Scanner.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Foundation

enum ScannerError: Error {
    case illegalChar
}

struct Scanner {
    let input: String
    var start: String.Index
    var position: String.Index
    var line = 1
    var isAtEnd: Bool {
        position == input.endIndex
    }
    var isAtLineEnding: Bool {
        peek == "\n" || peek == "\r" || peek == "\r\n"
    }
    var peek: Character {
        if isAtEnd { return "\0" }
        return input[position]
    }
   
    init(input: String) {
        self.input = input
        self.start = input.startIndex
        self.position = input.startIndex
    }
    
    mutating func scan() throws(ScannerError) -> [Token] {
        var tokens = [Token]()
        
        while !isAtEnd {
            start = position
            let c = advance()
            
            switch c {
            case "#": tokens.append(contentsOf: try readHeading())
            case "*":
                if peek == "*" {
                    tokens.append(contentsOf: try read(type: .star, type2: .star2, type3: .star3, c: "*"))
                } else {
                    tokens.append(token(.star))
                }
            case "=": tokens.append(token(.equal))
            case "-":
                if peek == "-" {
                    tokens.append(contentsOf: try read(type: .minus, type2: .minus2, type3: .minus3, c: "-"))
                } else {
                    tokens.append(token(.minus))
                }
            case ".": tokens.append(token(.dot))
            case "+": tokens.append(token(.plus))
            case "`":
                if peek == "`" {
                    tokens.append(contentsOf: try read(type: .tick, type2: .tick2, type3: .tick3, c: "`"))
                } else {
                    tokens.append(token(.tick))
                }
            case "[": tokens.append(token(.lbracket))
            case "]": tokens.append(token(.rbracket))
            case "(": tokens.append(token(.lparen))
            case ")": tokens.append(token(.rparen))
            case "<": tokens.append(token(.lt))
            case ">": tokens.append(token(.gt))
            case "!": tokens.append(token(.bang))
            case "_":
                if peek == "_" {
                    tokens.append(contentsOf: try read(type: .underscore, type2: .underscore2, type3: .underscore3, c: "_"))
                } else {
                    tokens.append(token(.underscore))
                }
            case "\\":
                start = position
                tokens.append(readText())
            case " ": break
            case "\r", "\n", "\r\n":
                tokens.append(Token(line: line, type: .lineEnding))
                line += 1
            default:
                if c.isNumber {
                    tokens.append(readNum())
                } else {
                    tokens.append(readText())
                }
            }
        }
        
        tokens.append(Token(line: line, type: .eof))
        
        return tokens
    }
    
    mutating func readText() -> Token {
        while !isAtLineEnding && !isAtEnd {
            advance()
        }
        
        let string = String(input[start..<position])
            .trimmingCharacters(in: .whitespaces)
        return Token(string: string, line: line, type: .text)
    }
    
    mutating func readHeading() throws(ScannerError) -> [Token] {
        var count = 1
        while peek == "#" {
            advance()
            count += 1
        }
        
        guard count <= 6 && peek == " " else {
            return [readText()]
        }
       
        return switch count {
        case 1: [token(.hash)]
        case 2: [token(.hash2)]
        case 3: [token(.hash3)]
        case 4: [token(.hash4)]
        case 5: [token(.hash5)]
        case 6: [token(.hash6)]
        default: throw .illegalChar
        }
    }
    
    mutating func read(type: TokenType, type2: TokenType, type3: TokenType, c: Character) throws(ScannerError) -> [Token] {
        var count = 1
        while peek == c {
            advance()
            count += 1
        }
        if count == 2 {
            return [token(type2)]
        } else if count == 3 {
            if c == "`" {
                var tokens = [Token]()
                tokens.append(token(type3))
                start = position
                while peek != "`" {
                    advance()
                    if peek == "\n" {
                        line += 1
                    }
                }
                let text = String(input[start..<position])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                count = 0
                while peek == "`" {
                    advance()
                    count += 1
                }
                if count != 3 {
                    throw .illegalChar
                }
                tokens.append(Token(string: text, line: line, type: .text))
                tokens.append(token(type3))
                return tokens
            } else {
                return [token(type3)]
            }
        } else if count > 3 {
            if c == "-" || c == "*" || c == "_" {
                return [token(type3)]
            }
        }
        return Array(repeating: token(type), count: count)
    }
    
    mutating func readNum() -> Token {
        while peek.isNumber {
            advance()
        }
        
        guard peek == "." else {
            return readText()
        }
        
        advance()
        let string = String(input[start..<position])
        return Token(string: string, line: line, type: .num)
    }
    
    func token(_ type: TokenType) -> Token {
        Token(line: line, type: type)
    }
    
    @discardableResult
    mutating func advance() -> Character {
        if isAtEnd {
            return "\0"
        }
        let prev = input[position]
        position = input.index(after: position)
        return prev
    }
}
