//
//  HTMLTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import MarkyMark

struct HTMLTests {
    func getHTML(input: String) throws -> String {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let markup = try p.parse()
        return markup.html()
    }
    
    func getHTMLMin(input: String) throws -> String {
        var s = Scanner(input: input)
        var p = Parser(tokens: try s.scan())
        let markup = try p.parse()
        return markup.min()
    }
    
    @Test func testLines() throws {
        let html = try getHTML(input: """
# heading 1

## heading 2

### heading 3

#### heading 4

##### heading 5

###### heading 6

####### not a heading

#not a heading

look at this paragraaaaph



""")
        
        let exp = """
<h1>heading 1</h1>

<h2>heading 2</h2>

<h3>heading 3</h3>

<h4>heading 4</h4>

<h5>heading 5</h5>

<h6>heading 6</h6>

<p>####### not a heading</p>

<p>#not a heading</p>

<p>look at this paragraaaaph</p>
"""
        #expect(html == exp)
    }
    
    @Test func testLinesMin() throws {
        let html = try getHTMLMin(input: """
# heading 1

## heading 2

### heading 3

#### heading 4

##### heading 5

###### heading 6

####### not a heading

#not a heading

look at this paragraaaaph
""")
        
        let exp = "<h1>heading 1</h1><h2>heading 2</h2><h3>heading 3</h3><h4>heading 4</h4><h5>heading 5</h5><h6>heading 6</h6><p>####### not a heading</p><p>#not a heading</p><p>look at this paragraaaaph</p>"
        #expect(html == exp)
    }
}

