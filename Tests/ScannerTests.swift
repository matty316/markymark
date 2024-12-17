//
//  ScannerTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import MarkyMark

struct ScannerTests {
    @Test func testScan() throws {
        let input = """
*=-_.+`\n[]\r\n()<>!
# ## ### #### ##### ###### 
- -- ---
* ** ***
_ __ ___
` `` 
```
func test() {
    print("hell nah")
}
```
word 2 23
2. this is a list
23 this is not
####### not a heading
"""
        let exp = [
            Token(string: "*", line: 1, type: .star),
            Token(string: "=", line: 1, type: .equal),
            Token(string: "-", line: 1, type: .minus),
            Token(string: "_", line: 1, type: .underscore),
            Token(string: ".", line: 1, type: .dot),
            Token(string: "+", line: 1, type: .plus),
            Token(string: "`", line: 1, type: .tick),
            Token(line: 1, type: .lineEnding),
            Token(string: "[", line: 2, type: .lbracket),
            Token(string: "]", line: 2, type: .rbracket),
            Token(line: 2, type: .lineEnding),
            Token(string: "(", line: 3, type: .lparen),
            Token(string: ")", line: 3, type: .rparen),
            Token(string: "<", line: 3, type: .lt),
            Token(string: ">", line: 3, type: .gt),
            Token(string: "!", line: 3, type: .bang),
            Token(line: 3, type: .lineEnding),
            Token(line: 4, type: .hash),
            Token(line: 4, type: .hash2),
            Token(line: 4, type: .hash3),
            Token(line: 4, type: .hash4),
            Token(line: 4, type: .hash5),
            Token(line: 4, type: .hash6),
            Token(line: 4, type: .lineEnding),
            Token(line: 5, type: .minus),
            Token(line: 5, type: .minus2),
            Token(line: 5, type: .minus3),
            Token(line: 5, type: .lineEnding),
            Token(line: 6, type: .star),
            Token(line: 6, type: .star2),
            Token(line: 6, type: .star3),
            Token(line: 6, type: .lineEnding),
            Token(line: 7, type: .underscore),
            Token(line: 7, type: .underscore2),
            Token(line: 7, type: .underscore3),
            Token(line: 7, type: .lineEnding),
            Token(line: 8, type: .tick),
            Token(line: 8, type: .tick2),
            Token(line: 8, type: .lineEnding),
            Token(line: 9, type: .tick3),
            Token(string: """
func test() {
    print("hell nah")
}
""",
                  line: 12, type: .text),
            Token(line: 12, type: .tick3),
            Token(line: 12, type: .lineEnding),
            Token(string: "word 2 23", line: 13, type: .text),
            Token(line: 13, type: .lineEnding),
            Token(string: "2.", line: 14, type: .num),
            Token(string: "this is a list", line: 14, type: .text),
            Token(line: 14, type: .lineEnding),
            Token(string: "23 this is not", line: 15, type: .text),
            Token(line: 15, type: .lineEnding),
            Token(string: "####### not a heading", line: 16, type: .text),
            Token(line: 16, type: .eof)
        ]
        
        var s = Scanner(input: input)
        let tokens = try s.scan()
        for (i, token) in tokens.enumerated() {
            let expToken = exp[i]
            #expect(token.line == expToken.line)
            #expect(token.string == expToken.string)
            #expect(token.type == expToken.type)
        }
    }
}
