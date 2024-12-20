//
//  LineScannerTests.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/19/24.
//

import Testing
@testable import MarkyMark

struct LineScannerTests {
    func scan(input: String) throws -> [Token] {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let m = try p.parse()
        let l = m.elements.first as! Line
        var ls = LineScanner(content: l.content)
        return try ls.scan()
    }
    
    @Test(arguments: zip([
        "this is a paragraph with ***emphasis baby***",
        "this is a paragraph with **emphasis baby**",
        "this is a paragraph with *emphasis baby*",
        "this is a paragraph with ___emphasis baby___",
        "this is a paragraph with __emphasis baby__",
        "this is a paragraph with _emphasis baby_",
    ], [
        TokenType.star3,
        TokenType.star2,
        TokenType.star,
        TokenType.underscore3,
        TokenType.underscore2,
        TokenType.underscore
    ]))
    func testEmphasis(input: String, type: TokenType) throws {
        let expTokens = [
            Token(string: "this is a paragraph with "),
            Token(type: type),
            Token(string: "emphasis baby"),
            Token(type: type),
        ]
        
        let tokens = try scan(input: input)
        
        #expect(tokens.count == expTokens.count)
        for (i, t) in tokens.enumerated() {
            let exp = expTokens[i]
            #expect(exp.string == t.string)
            #expect(exp.type == t.type)
        }
    }
    
    @Test(arguments: zip([
        "this is a paragraph with a link to [sonic the hedgehog](https://www.sonicthehedgehog.com/)",
        "this is a paragraph with a link to [shameless plug](https://www.youtube.com/@4nem_matty)"
    ], [
        ("https://www.sonicthehedgehog.com/", "sonic the hedgehog"),
        ("https://www.youtube.com/@4nem_matty", "shameless plug")
    ])) func testLink(input: String, exp: (link: String, text: String)) throws {
        let tokens = try scan(input: input)
        let expTokens = [
            Token(string: "this is a paragraph with a link to "),
            Token(type: .lbracket),
            Token(string: exp.text),
            Token(type: .rbracket),
            Token(type: .lparen),
            Token(string: exp.link),
            Token(type: .rparen)
        ]
        
        #expect(tokens.count == expTokens.count)
        for (i, t) in tokens.enumerated() {
            let exp = expTokens[i]
            #expect(exp.string == t.string)
            #expect(exp.type == t.type)
        }
    }
    
    @Test func testInlineCode() throws {
        let input = "this has `inline code`"
        let expTokens = [
            Token(string: "this has "),
            Token(type: .tick),
            Token(string: "inline code"),
            Token(type: .tick)
        ]
        
        let tokens = try scan(input: input)
        
        #expect(tokens.count == expTokens.count)
        for (i, token) in tokens.enumerated() {
            let exp = expTokens[i]
            #expect(exp.string == token.string)
            #expect(exp.type == token.type)
        }
    }
}
