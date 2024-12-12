//
//  MarkMark.swift
//  MarkyMark
//
//  Created by Matthew Reed on 12/12/24.
//

public struct MarkMark {
    public static func parse(_ input: String) throws -> Markup {
        var scanner = Scanner(input: input)
        let tokens = try scanner.scan()
        var parser = Parser(tokens: tokens)
        return try parser.parse()
    }
}

