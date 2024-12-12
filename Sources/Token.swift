//
//  Token.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

struct Token {
    let string: String
    let line: Int
    let type: TokenType
    
    init(string: String, line: Int, type: TokenType) {
        self.string = string
        self.line = line
        self.type = type
    }
    
    init(line: Int, type: TokenType) {
        self.string = type.rawValue
        self.line = line
        self.type = type
    }
}

enum TokenType: String {
    case hash = "#", hash2 = "##", hash3 = "###", hash4 = "####", hash5 = "#####", hash6 = "######"
    case star = "*", star2 = "**", star3 = "***", num
    case equal = "="
    case minus = "-", minus2 = "--", minus3 = "---"
    case underscore = "_", underscore2 = "__", underscore3 = "___"
    case dot = "."
    case plus = "+"
    case tick = "`", tick2 = "``", tick3 = "```"
    case lbracket = "[", rbracket = "]", lparen = "(", rparen = ")", lt = "<", gt = ">", bang = "!", backslash = "\\"
    case text
    case blank, lineEnding, eof
}
